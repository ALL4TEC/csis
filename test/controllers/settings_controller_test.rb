# frozen_string_literal: true

require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated staff cannot reset certificate bg image' do
    post settings_reset_path, params: {
      reset: :background
    }
    check_not_authenticated
  end

  test 'authenticated staff cannot reset certificate bg image' do
    sign_in users(:staffuser)
    post settings_reset_path, params: {
      reset: :background
    }
    assert_redirected_to root_path
  end

  test 'authenticated cyberanalyst cannot reset certificate bg image' do
    sign_in users(:cyberanalyst)
    post settings_reset_path, params: {
      reset: :background
    }
    assert_redirected_to root_path
  end

  test 'authenticated cyberadmin cannot reset certificate bg image' do
    sign_in users(:cyberadmin)
    post settings_reset_path, params: {
      reset: :background
    }
    assert_redirected_to root_path
  end

  test 'authenticated superadmin can reset certificate bg image' do
    sign_in users(:superadmin)
    post settings_certificates_bg_path, params: {
      background: fixture_file_upload('settings/fondPDF.jpg', 'image/jpeg')
    }
    assert Branding.singleton.certificate_bg.attached?
    post settings_reset_path, params: {
      reset: :background
    }
    assert_equal I18n.t('settings.notices.reset_success'), flash[:notice]
    assert_not Branding.singleton.certificate_bg.attached?
  end

  test 'unauthenticated staff cannot reset certificate thumbnail images' do
    post settings_reset_path, params: {
      reset: :thumbnail
    }
    check_not_authenticated
  end

  test 'authenticated staff cannot reset certificate thumbnail images' do
    sign_in users(:staffuser)
    post settings_reset_path, params: {
      reset: :thumbnail
    }
    assert_redirected_to root_path
  end

  test 'authenticated cyberanalyst cannot reset certificate thumbnail images' do
    sign_in users(:cyberanalyst)
    post settings_reset_path, params: {
      reset: :thumbnail
    }
    assert_redirected_to root_path
  end

  test 'authenticated cyberadmin cannot reset certificate thumbnail images' do
    sign_in users(:cyberadmin)
    post settings_reset_path, params: {
      reset: :thumbnail
    }
    assert_redirected_to root_path
  end

  test 'authenticated superadmin can reset certificate thumbnail images' do
    sign_in users(:superadmin)
    post settings_wsc_thumbs_path, params: {
      thumbnail: fixture_file_upload('settings/WSC_full.png', 'image/png'),
      size: 'full'
    }
    assert Branding.singleton.wsc_full.attached?
    post settings_reset_path, params: {
      reset: :thumbnail
    }
    assert_equal I18n.t('settings.notices.reset_success'), flash[:notice]
    assert_not Branding.singleton.wsc_full.attached?
  end

  test 'authenticated superadmin cannot reset any images' do
    sign_in users(:superadmin)
    post settings_reset_path, params: {
      reset: :image
    }
    assert_equal I18n.t('settings.notices.reset_failure'), flash[:alert]
  end

  test 'unauthenticated staff cannot reset certificate text colors' do
    color = Customization.first
    post settings_customize_path, params: {
      do: :reset,
      key: color.key,
      value: color.value
    }
    check_not_authenticated
  end

  test 'authenticated staff cannot reset certificate text colors' do
    color = Customization.first
    sign_in users(:staffuser)
    post settings_customize_path, params: {
      do: :reset,
      key: color.key,
      value: color.value
    }
    assert_redirected_to root_path
  end

  test 'authenticated cyberanalyst cannot reset certificate text colors' do
    color = Customization.first
    sign_in users(:cyberanalyst)
    post settings_customize_path, params: {
      do: :reset,
      key: color.key,
      value: color.value
    }
    assert_redirected_to root_path
  end

  test 'authenticated cyberadmin cannot reset certificate text colors' do
    color = Customization.first
    sign_in users(:cyberadmin)
    post settings_customize_path, params: {
      do: :reset,
      key: color.key,
      value: color.value
    }
    assert_redirected_to root_path
  end

  test 'authenticated superadmin can reset certificate text colors' do
    color = Customization.first
    sign_in users(:superadmin)
    post settings_customize_path, params: {
      do: :reset,
      key: color.key,
      value: color.value
    }
    assert_equal I18n.t('settings.notices.customize_success'), flash[:notice]
    assert_raises ActiveRecord::RecordNotFound do
      Customization.find(color.id)
    end
  end

  test 'authenticated superadmin can set certificate text colors' do
    color = Customization.first
    sign_in users(:superadmin)
    post settings_customize_path, params: {
      do: :set,
      key: color.key,
      value: color.value
    }
    assert_equal I18n.t('settings.notices.customize_success'), flash[:notice]
    assert Customization.find(color.id).present?
  end

  test 'authenticated superadmin cannot reset any color' do
    sign_in users(:superadmin)
    post settings_customize_path, params: {
      do: :reset,
      key: 'any color',
      value: '#000000'
    }
    assert_equal I18n.t('settings.notices.customize_failure'), flash[:alert]
  end

  test 'authenticated superadmin cannot set any color' do
    sign_in users(:superadmin)
    post settings_customize_path, params: {
      do: :set,
      key: 'any color',
      value: '#000000'
    }
    assert_equal I18n.t('settings.notices.customize_failure'), flash[:alert]
  end
end
