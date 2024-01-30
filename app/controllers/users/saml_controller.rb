# frozen_string_literal: true

class Users::SamlController < ApplicationController
  protect_from_forgery except: %i[consume]
  before_action :set_idp_config

  # GET /users/auth/saml/init/:idp
  def init
    request = OneLogin::RubySaml::Authrequest.new
    logger.info "Idp #{@idp_config}: Initiating SAML workflow"
    redirect_to(request.create(saml_settings), allow_other_host: true)
  end

  # POST /users/auth/saml/consume/:idp
  def consume
    logger.info "Idp #{@idp_config}: Consuming data"
    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse],
      settings: saml_settings,
      allowed_clock_drift: Rails.application.config.saml_clock_drift)
    response.settings = saml_settings

    email = response.attributes['Email']
    logger.info "Idp #{@idp_config}: Response:#{response}"
    logger.info "Idp #{@idp_config}: Response attributes:#{response.attributes}"
    if email.nil? || User.find_by(email: email, state: :actif).nil?
      flash[:alert] = t 'users.errors.unauthorized_email'
      logger.info "Idp #{@idp_config}: Unauthorized email"
      return redirect_to new_user_session_path
    end
    @user = User.from_saml(response, @idp_config.name)
    logger.info "Idp #{@idp_config}: User found: #{@user}"
    return unless @user.persisted?

    flash[:notice] = t 'devise.omniauth_callbacks.success', kind: @idp_config.name
    PaperTrail::Version.create(
      item_type: 'User',
      item_id: @user.id,
      event: 'connection',
      whodunnit: @user.id
    )
    redirect_path = params[:RelayState].presence || root_path
    logger.info "Idp #{@idp_config}: #{@user} redirected to #{redirect_path}"
    store_location_for(@user, redirect_path)
    sign_in_and_redirect @user, event: :authentication
  end

  # GET /users/auth/saml/meta/:idp
  def metadata
    logger.info "Accessing metadata for #{@idp_config}"
    meta = OneLogin::RubySaml::Metadata.new
    render xml: meta.generate(saml_settings), content_type: 'application/samlmetadata+xml'
  end

  # Trigger SP and IdP initiated Logout requests
  # GET /users/auth/saml/logout
  def logout
    # If we're given a logout request, handle it in the IdP logout initiated method
    if params[:SAMLRequest]
      idp_logout_request
    # We've been given a response back from the IdP, process it
    elsif params[:SAMLResponse]
      process_logout_response
    # Initiate SLO (send Logout Request)
    else
      sp_logout_request
    end
  end

  private

  def set_idp_config
    handle_unscoped do
      @idp_config = if params[:idp].present?
                      IdpConfig.active.find(params[:idp])
                    else
                      IdpConfig.active.find_by(name: current_user.provider) # Logout
                    end
    end
  end

  # Create a SP initiated SLO: If user logged in via saml, click on logout leads to this method
  def sp_logout_request
    # LogoutRequest accepts plain browser requests w/o paramters
    settings = saml_settings

    if settings.idp_slo_target_url.nil?
      logger.info "Idp #{@idp_config}: SLO IdP Endpoint not found in settings, \
                   executing then a normal logout'"
      delete_session(redirect_to: login_path)
    else
      # Since we created a new SAML request, save the transaction_id
      # to compare it with the response we get back
      logout_request = OneLogin::RubySaml::Logoutrequest.new
      session[:transaction_id] = logout_request.uuid
      info = "Idp #{@idp_config}: New SP SLO for user:'#{current_user.id}'| \
              transaction:'#{session[:transaction_id]}'"
      logger.info(info)

      settings.name_identifier_value = current_user.id if settings.name_identifier_value.nil?

      relay_state = url_for controller: 'users/saml', action: 'logout' # saml_logout_path
      redirect_to(logout_request.create(settings, RelayState: relay_state), allow_other_host: true)
    end
  end

  # After sending an SP initiated LogoutRequest to the IdP, we need to accept
  # the LogoutResponse, verify it, then actually delete our session.
  def process_logout_response
    settings = saml_settings

    if session.key? :transaction_id
      logout_response = OneLogin::RubySaml::Logoutresponse.new(
        params[:SAMLResponse], settings, matches_request_id: session[:transaction_id]
      )
    else
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings)
    end

    logger.info "Idp #{@idp_config}: LogoutResponse is: #{logout_response}"

    # Validate the SAML Logout Response
    if logout_response.validate
      logger.info "Idp #{@idp_config}: Delete session for '#{current_user.id}'"
      delete_session(redirect_to: login_path)
    else
      # Actually log out this session
      logger.error "Idp #{@idp_config}: The SAML Logout Response is invalid"
      render inline: logger.error
    end
  end

  # Method to handle IdP initiated logouts
  def idp_logout_request
    settings = saml_settings
    logout_request = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest])
    unless logout_request.is_valid?
      logger.error "IdP #{@idp_config}: initiated LogoutRequest was not valid!"
      return render inline: logger.error
    end
    logger.info "IdP #{@idp_config}: initiated Logout for #{logout_request.name_id}"

    # Actually log out this session
    delete_session

    # Generate a response to the IdP.
    logout_request_id = logout_request.id
    logout_response = OneLogin::RubySaml::SloLogoutresponse.new.create(
      settings, logout_request_id, nil, RelayState: params[:RelayState]
    )
    redirect_to(logout_response, allow_other_host: true)
  end

  # Delete a user's session.
  def delete_session(opts = {})
    session[:attributes] = nil
    sign_out current_user
    redirect_to opts[:redirect_to] if opts.key?(:redirect_to)
  end

  def saml_settings
    settings = OneLogin::RubySaml::Settings.new
    # Base des urls du SP CSIS
    base_url = "https://#{request.host}/users/auth/saml"

    idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
    meta_url = @idp_config.idp_metadata_url
    if @idp_config.idp_entity_id.present?
      if meta_url.present?
        validate_cert = true
        settings = idp_metadata_parser.parse_remote(meta_url, validate_cert,
          entity_id: @idp_config.idp_entity_id)
      else
        @idp_config.idp_metadata_xml.open do |file|
          settings = idp_metadata_parser.parse(file.read,
            entity_id: @idp_config.idp_entity_id)
        end
      end
    elsif meta_url.present?
      # Returns OneLogin::RubySaml::Settings prepopulated with idp metadata
      # Following are set:
      # idp_entity_id
      # name_identifier_format
      # idp_sso_target_url
      # idp_slo_target_url
      # idp_attribute_names
      # idp_cert
      # idp_cert_fingerprint
      # idp_cert_multi
      settings = idp_metadata_parser.parse_remote(meta_url)
    else
      @idp_config.idp_metadata_xml.open do |file|
        settings = idp_metadata_parser.parse(file.read)
      end
    end

    settings.assertion_consumer_service_url = "#{base_url}/consume/#{@idp_config.id}"
    settings.sp_entity_id = "#{base_url}/meta/#{@idp_config.id}"
    settings.name_identifier_format = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'

    # SP for signature and decryption
    settings.certificate = @idp_config.certificate
    settings.private_key = @idp_config.private_key

    conf = Rails.application.config
    settings.security = {
      authn_requests_signed: conf.saml_authn_requests_signed,
      logout_requests_signed: conf.saml_logout_requests_signed,
      logout_responses_signed: conf.saml_logout_responses_signed,
      want_assertions_signed: conf.saml_want_assertions_signed,
      metadata_signed: conf.saml_metadata_signed,
      digest_method: conf.saml_digest_method,
      signature_method: conf.saml_signature_method,
      embed_sign: conf.saml_embed_sign,
      check_idp_cert_expiration: conf.saml_check_idp_cert_expiration,
      check_sp_cert_expiration: conf.saml_check_sp_cert_expiration
    }

    settings
  end
end
