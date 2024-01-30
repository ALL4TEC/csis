# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/autorun'
require 'minitest/stub_any_instance'
require 'minitest/reporters'
# require 'appmap/minitest'

Minitest::Reporters.use!(
  # [Minitest::Reporters::DefaultReporter.new, Minitest::Reporters::HtmlReporter.new],
  Minitest::Reporters::DefaultReporter.new,
  ENV,
  Minitest.backtrace_filter
)

module Gpg
  TESTS_PUB_KEY = 'test/fixtures/files/public_tests_key.asc'
end

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def json_mime
      'application/json'
    end

    def xml_mime
      'application/xml'
    end

    def check_not_authenticated
      assert_redirected_to login_path
    end

    def check_not_authorized(url = root_url)
      assert_redirected_to url
      assert_equal I18n.t('actions.notices.no_rights'), flash[:alert]
    end

    def check_unscoped(url = root_url)
      assert_redirected_to url
      assert_equal I18n.t('activerecord.errors.not_found'), flash[:alert]
    end

    def check_unauthorized
      assert_response :unauthorized
      assert(response.body['error'].present?, 'Error message should be present')
    end

    def check_loggedin_user
      get dashboard_path
      assert_response :success
    end

    def check_loggedout_user
      get dashboard_path
      check_not_authenticated
    end
  end
end

# Integration tests
module RemoveUploadedFiles
  def after_teardown
    super
    remove_uploaded_files
  end

  private

  def remove_uploaded_files
    # tmp/storage is configured under test block in config/storage.yml,
    # maybe another way to access it...
    FileUtils.rm_rf(Rails.root.join('tmp/storage'))
  end
end

module RemoveGeneratedCertificates
  def after_teardown
    super
    remove_test_certificates
  end

  private

  def remove_test_certificates
    FileUtils.rm_rf(AssetsUtil::WSC_DIR)
  end
end

module ActionDispatch
  class IntegrationTest
    prepend RemoveUploadedFiles
  end
end

require 'mocha/minitest'
