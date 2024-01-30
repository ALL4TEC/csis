# frozen_string_literal: true

require 'test_helper'

class FakeResponse
  attr_accessor :settings, :attributes, :nameid

  def initialize(email, first_name, last_name)
    @attributes = {
      'Email' => email,
      'Avatar' => 'avatar.url',
      'First Name' => first_name,
      'Last Name' => last_name
    }
    @nameid = '123545'
  end
end

class FakeSloLogoutrequest
  attr_accessor :id, :name_id, :valid

  def initialize(_id, valid)
    @valid = valid
  end

  # rubocop:disable Naming/PredicateName
  def is_valid?
    @valid
  end
  # rubocop:enable Naming/PredicateName
end

class FakeLogoutresponse
  attr_accessor :valid

  def initialize(valid)
    @valid = valid
  end

  def to_s
    'FakeLogoutResponse'
  end

  def validate
    @valid
  end
end

class SamlTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  FAKE_SETTINGS = {
    idp_entity_id: 'https://app.onelogin.com/saml/metadata/2c68fa02-81ec-4f22-b2ec-07a8d6a60c23',
    name_identifier_format: 'Email',
    idp_sso_target_url: 'https://xxx-dev.onelogin.com/trust/saml2/http-post/sso/2c68fa02-81ec-4f22-b2ec-07a8d6a60c23',
    idp_slo_target_url: 'https://xxx-dev.onelogin.com/trust/saml2/http-redirect/slo/1172867',
    idp_attribute_names: '',
    idp_cert: 'certificate',
    idp_cert_fingerprint: 'fingerprint',
    idp_cert_multi: false
  }.freeze

  test 'unauthenticated can initialize SAML flow if knowing idp_config id' do
    stub_settings do
      get saml_init_path('ABC')
      check_unscoped
      get saml_init_path(IdpConfig.active.first.id)
      assert_redirected_to(/\A#{FAKE_SETTINGS[:idp_sso_target_url]}\?SAMLRequest=.*/)
    end
  end

  test 'unauthenticated can see Idp config metadata if kwnowing idp_config id' do
    stub_settings do
      get saml_metadata_path('ABC')
      check_unscoped
      get saml_metadata_path(IdpConfig.active.first.id)
      assert_equal response['Content-Type'], 'application/samlmetadata+xml; charset=utf-8'
    end
  end

  test 'Idp can initiate logout to logout user in csis' do
    sign_in users(:samuel)
    check_loggedin_user
    stub_settings do
      id = '1234'
      saml_request = 'SomethingEncoded'
      relay_state = 'http://idp_url/logout/callback'
      # When invalid request, render inline error
      OneLogin::RubySaml::SloLogoutrequest.stub(:new, mock_idp_slo_request(id, false)) do
        get saml_logout_path(SAMLRequest: saml_request, RelayState: relay_state)
        assert_response :success
        check_loggedin_user # not logged out
      end
      OneLogin::RubySaml::SloLogoutrequest.stub(:new, mock_idp_slo_request(id, true)) do
        redirection = 'somepath'
        OneLogin::RubySaml::SloLogoutresponse.stub_any_instance(:create, redirection) do
          get saml_logout_path(SAMLRequest: saml_request, RelayState: relay_state)
          assert_redirected_to redirection
          check_loggedout_user # logged out
        end
      end
    end
  end

  test 'SP can initiate logout to logout user in Idp too only if idp_slo_target_url present' do
    sign_in users(:samuel)
    check_loggedin_user
    # SLO IdP Endpoint not found in settings, executing then a normal logout'
    stub_settings({ idp_slo_target_url: nil }) do
      get saml_logout_path
      check_not_authenticated
      check_loggedout_user # logged out
    end
    sign_in users(:samuel)
    check_loggedin_user
    # SLO IdP Endpoint found in settings
    stub_settings do
      get saml_logout_path
      assert_redirected_to(/\A#{FAKE_SETTINGS[:idp_slo_target_url]}\?SAMLRequest=.*/)
      check_loggedin_user # Still logged in
    end
  end

  test 'SP must validate a logout response callback from Idp to logout' do
    sign_in users(:samuel)
    check_loggedin_user
    stub_settings do
      saml_response = 'something'
      # If invalid response, no logout
      OneLogin::RubySaml::Logoutresponse.stub(:new, mock_idp_slo_response(false)) do
        get saml_logout_path(SAMLResponse: saml_response)
        assert_response :success
        check_loggedin_user
      end
      # If valid response, logout
      OneLogin::RubySaml::Logoutresponse.stub(:new, mock_idp_slo_response(true)) do
        get saml_logout_path(SAMLResponse: saml_response)
        check_not_authenticated
        check_loggedout_user
      end
    end
  end

  test 'user can log in to root_path via saml if email present in database without RelayState' do
    test_consume('staff.user@somedomain.com', 'Louis', 'Person', true)
  end

  test 'user can log in to RS via saml if email present in database with RelayState' do
    test_consume('staff.user@somedomain.com', 'Louis', 'Person', true, dashboard_path)
  end

  test 'user cannot log in via saml if email not present in database' do
    test_consume('unknown.person@mystery.com', 'Unknown', 'Person', false)
  end

  test 'user cannot log in via saml if account not activated' do
    test_consume('inactif@somedomain.eu', 'inactif', '', false)
  end

  private

  def mock_saml_response_ok(email, first_name, last_name)
    FakeResponse.new(email, first_name, last_name)
  end

  def mock_idp_slo_request(id, valid)
    FakeSloLogoutrequest.new(id, valid)
  end

  def mock_idp_slo_response(valid)
    FakeLogoutresponse.new(valid)
  end

  def assert_auth(auth_ok, relay_state = nil)
    if auth_ok
      assert_redirected_to relay_state.presence || root_path
    else
      check_not_authenticated
    end
  end

  def test_consume(email, first_name, last_name, auth_ok, relay_state = nil)
    OneLogin::RubySaml::Response.stub(
      :new, mock_saml_response_ok(email, first_name, last_name)
    ) do
      stub_settings do
        config = IdpConfig.active.first
        get saml_init_path(config.id)
        assert_redirected_to(/\A#{FAKE_SETTINGS[:idp_sso_target_url]}\?SAMLRequest=.*/)
        params = {
          SAMLResponse: 'osef'
        }
        params[:RelayState] = relay_state if relay_state.present?
        post saml_consume_path(config.id), params: params
        assert_auth(auth_ok, relay_state)
      end
    end
  end

  def stub_settings(opts = {}, &block)
    settings = OneLogin::RubySaml::Settings.new(FAKE_SETTINGS.merge(opts))
    OneLogin::RubySaml::IdpMetadataParser.stub_any_instance(:parse_remote, settings, &block)
  end
end
