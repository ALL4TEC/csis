# frozen_string_literal: true

class SettingsController < ApplicationController
  include BouncerController

  SEVERITY_CUSTOMIZATIONS = %w[low medium high critical].map { |v| "cvss_to_severity_#{v}" }
  OVERRIDABLE = %w[reports_logo mails_logo background thumbnail badge webicon
                   cvss_to_severity].freeze

  # GET /settings
  def index
    @app_section = make_section_header(title: t('settings.section_title'))
  end

  # POST /settings/certificates/bg
  def upload_certificates_bg
    return if params[:background].blank?

    upload_image(params[:background], :certificate_bg, 'image/jpeg')
  end

  # POST /settings/reports/logo
  def upload_reports_logo
    upload_image(params[:reports_logo], :reports_logo) if params[:reports_logo].present?
  end

  # POST /settings/mails/logo
  def upload_mails_logo
    upload_image(params[:mails_logo], :mails_logo) if params[:mails_logo].present?
  end

  # POST /settings/mails/webicons
  def upload_mails_webicons
    content = params[:webicon]
    identifier = params[:social]
    if content.present? && params[:social_url].present?
      if identifier.present?
        if content.content_type == 'image/png'
          Branding.singleton.send(:"#{params[:social]}_webicon").attach(params[:webicon])
          Branding.singleton.update!("#{identifier}_url": params[:social_url])
          flash.now[:notice] = t('settings.notices.success')
        else
          flash[:alert] = t('settings.notices.type_error')
        end
      else
        flash[:alert] = t('settings.notices.filename_error')
      end
    elsif identifier.present?
      flash.now[:alert] = t('settings.notices.missing_image_error')
    end
    redirect_to settings_path
  end

  # POST /settings/wsc/thumbs
  def upload_wsc_thumbs
    upload_image_among(params[:thumbnail], params[:size]) do
      Branding.singleton.send(:"wsc_#{params[:size]}").attach(params[:thumbnail])
    end
  end

  # POST /settings/badges
  def upload_badges
    upload_image_among(params[:badge], params[:level]) do
      Branding.singleton.send(:"#{params[:level]}_badge").attach(params[:badge])
    end
  end

  # POST /settings/gpg/key
  # upload gpg key (must correspond to specified ACTIONS_EMAIL)
  # def upload_gpg_key
  # end

  # PUT /settings/stats
  # Update Certificate, Project Statistics and Report Statistics
  def update_certs_and_stats
    # Update Certificates and Statistics
    Project.all.includes([{ certificate: :languages, statistics: :reports }]).find_each do |p|
      handle_project_statistics(p)
      handle_project_certificate(p)
    end

    redirect_to settings_path, notice: t('settings.notices.updated')
  end

  # POST /settings/reset
  # Reset overriden values to default ones
  def reset
    if params[:reset].in?(OVERRIDABLE)
      branding = Branding.singleton
      case params[:reset]
      when 'background'
        branding.certificate_bg.purge
      when 'reports_logo'
        branding.reports_logo.purge
      when 'mails_logo'
        branding.mails_logo.purge
      when 'webicon'
        branding.reset_webicons
      when 'thumbnail'
        branding.reset_wsc
      when 'badge'
        branding.reset_badges
      when 'cvss_to_severity'
        Customization.where("key LIKE 'cvss_to_severity%'").find_each(&:destroy)
      end
      flash[:notice] = t('settings.notices.reset_success')
    else
      flash[:alert] = t('settings.notices.reset_failure')
    end
    redirect_to settings_path
  end

  # POST /settings/customize
  def customize
    if params[:do].in?(%w[set reset]) && params[:key].in?(Certificate::CUSTOMIZABLE_FIELDS)
      handle_certificate_customizations
    elsif !(SEVERITY_CUSTOMIZATIONS & params.keys).empty?
      handle_severity_customizations
    else
      flash[:alert] = t('settings.notices.customize_failure')
    end
    redirect_to settings_path
  end

  private

  def handle_certificate_customizations
    if params[:do] == 'reset'
      Customization.find_by(key: params[:key])&.destroy
      flash.now[:notice] = t('settings.notices.customize_success')
    else
      custom = Customization.find_or_initialize_by(key: params[:key])
      custom.value = params[:value]
      if custom.save
        flash.now[:notice] = t('settings.notices.customize_success')
      else
        flash.now[:alert] = t('settings.notices.customize_failure')
      end
    end
  end

  def handle_severity_customizations
    (SEVERITY_CUSTOMIZATIONS & params.keys).each do |key|
      # is float between 0.1 and 9.9?
      # to_f returns 0.0 if string isn't a number
      if params[key].to_f.positive? && params[key].to_f < 10
        custom = Customization.find_or_initialize_by(key: key)
        custom.value = params[key]
        unless custom.save
          flash[:alert] = t('settings.notices.customize_failure')
          break
        end
      else
        flash[:alert] = t('settings.notices.customize_failure')
        break
      end
    end
    flash.now[:notice] = t('settings.notices.customize_success')
  end

  def authorize!
    authorize(:settings)
  end

  # If param[:account] does not give user authorized QualysConfig, display error
  def account_specified
    return if params[:account].present? && policy_scope(QualysConfig).find(params[:account])

    redirect_to :settings, alert: t('settings.notices.missing_account')
  end

  # If no statistics, create new
  # Else update existing
  def handle_project_statistics(project)
    if project.statistics.nil?
      Statistic.create(project: project)
    else
      project.statistics.update_stats
    end
  end

  # If no certificate, create new
  # Else update existing
  def handle_project_certificate(project)
    if project.certificate.nil?
      Certificate.create(project: project)
    else
      project.certificate.update_certificate
    end
  end

  #
  # Upload an image among others identified by identifier
  # **@params content:** Image content
  # **@params identifier:** Among identifier
  # **@params type:** Image content_type
  # **@params block:** Block yielded if everything is ok
  def upload_image_among(content, identifier, type = 'image/png', &block)
    if content.present?
      if identifier.present?
        if content.content_type == type
          yield block
          flash.now[:notice] = t('settings.notices.success')
        else
          flash[:alert] = t('settings.notices.type_error')
        end
      else
        flash[:alert] = t('settings.notices.filename_error')
      end
    elsif identifier.present?
      flash.now[:alert] = t('settings.notices.missing_image_error')
    end
    redirect_to settings_path
  end

  #
  # Upload an image
  #
  # **@params content:** Image content
  # **@params has_one_sym:** Branding has_one_attached symbol to attach image to
  # **@params type:** Image type
  def upload_image(content, has_one_sym, type = 'image/png')
    if content.content_type == type
      Branding.singleton.send(has_one_sym).attach(content)
      flash.now[:notice] = t('settings.notices.success')
    else
      flash.now[:alert] = t('settings.notices.type_error')
    end
    redirect_to settings_path
  end
end
