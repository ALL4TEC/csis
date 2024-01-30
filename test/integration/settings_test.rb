# frozen_string_literal: true

require 'test_helper'

class SettingsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'authenticated super_admin only can view settings page' do
    sign_in users(:staffuser)
    get settings_path
    check_not_authorized
    sign_in users(:superadmin)
    get settings_path
    assert_response 200
  end

  test 'unauthenticated cannot view settings page' do
    get settings_path
    check_not_authenticated
  end

  ### PDF BG ###

  test 'authenticated super_admin only can upload certificate background' do
    sign_in users(:staffuser)
    post settings_certificates_bg_path, params:
      {
        background: fixture_file_upload('settings/fondPDF.jpg', 'image/jpeg')
      }
    check_not_authorized
    sign_in users(:superadmin)
    post settings_certificates_bg_path, params:
      {
        background: fixture_file_upload('settings/fondPDF.jpg', 'image/jpeg')
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
  end

  test 'authenticated super_admin cannot upload certificate background with wrong type' do
    sign_in users(:superadmin)
    post settings_certificates_bg_path, params:
      {
        background: fixture_file_upload('settings/fondPDF.png', 'image/png')
      }
    assert_equal I18n.t('settings.notices.type_error'), flash[:alert]
  end

  test 'unauthenticated cannot upload certificate background' do
    post settings_certificates_bg_path, params:
      {
        background: fixture_file_upload('settings/fondPDF.jpg', 'image/jpeg')
      }
    check_not_authenticated
  end

  ### REPORTS LOGO ###

  test 'authenticated super_admin only can upload reports logo' do
    sign_in users(:staffuser)
    post settings_reports_logo_path, params:
      {
        reports_logo: fixture_file_upload('settings/logo.png', 'image/png')
      }
    check_not_authorized
    sign_in users(:superadmin)
    post settings_reports_logo_path, params:
      {
        reports_logo: fixture_file_upload('settings/logo.png', 'image/png')
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
  end

  test 'authenticated super_admin cannot upload reports logo with wrong type' do
    sign_in users(:superadmin)
    post settings_reports_logo_path, params:
      {
        reports_logo: fixture_file_upload('settings/logo.jpeg', 'image/jpeg')
      }
    assert_equal I18n.t('settings.notices.type_error'), flash[:alert]
  end

  test 'unauthenticated cannot upload reports logo' do
    post settings_reports_logo_path, params:
      {
        reports_logo: fixture_file_upload('settings/logo.png', 'image/png')
      }
    check_not_authenticated
  end

  ### MAILS LOGO ###

  test 'authenticated super_admin only can upload mails logo' do
    sign_in users(:staffuser)
    post settings_mails_logo_path, params:
      {
        mails_logo: fixture_file_upload('settings/logo.png', 'image/png')
      }
    check_not_authorized
    sign_in users(:superadmin)
    post settings_mails_logo_path, params:
      {
        mails_logo: fixture_file_upload('settings/logo.png', 'image/png')
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
  end

  test 'authenticated super_admin cannot upload mails logo with wrong type' do
    sign_in users(:superadmin)
    post settings_mails_logo_path, params:
      {
        mails_logo: fixture_file_upload('settings/logo.jpeg', 'image/jpeg')
      }
    assert_equal I18n.t('settings.notices.type_error'), flash[:alert]
  end

  test 'unauthenticated cannot upload mails logo' do
    post settings_mails_logo_path, params:
      {
        mails_logo: fixture_file_upload('settings/logo.png', 'image/png')
      }
    check_not_authenticated
  end

  #### MAILS WEBICONS

  test 'authenticated super_admin only can upload mails webicon' do
    sign_in users(:staffuser)
    post settings_mails_webicons_path, params:
      {
        webicon: fixture_file_upload('settings/webicon-twitter.png', 'image/png'),
        social: 'twitter',
        social_url: 'http://somedomain.com/twitter'
      }
    check_not_authorized
    sign_in users(:superadmin)
    post settings_mails_webicons_path, params:
      {
        webicon: fixture_file_upload('settings/webicon-twitter.png', 'image/png'),
        social: 'twitter',
        social_url: 'http://somedomain.com/twitter'
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
  end

  test 'authenticated super_admin can upload mails webicons for each social' do
    sign_in users(:superadmin)
    post settings_mails_webicons_path, params:
      {
        webicon: fixture_file_upload('settings/webicon-linkedin.png', 'image/png'),
        social: 'linkedin',
        social_url: 'http://somedomain.com/linkedin'
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
    post settings_mails_webicons_path, params:
      {
        webicon: fixture_file_upload('settings/webicon-twitter.png', 'image/png'),
        social: 'twitter',
        social_url: 'http://somedomain.com/linkedin'
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
    post settings_mails_webicons_path, params:
      {
        webicon: fixture_file_upload('settings/webicon-facebook.png', 'image/png'),
        social: 'facebook',
        social_url: 'http://somedomain.com/facebook'
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
    post settings_mails_webicons_path, params:
      {
        webicon: fixture_file_upload('settings/webicon-pinterest.png', 'image/png'),
        social: 'pinterest',
        social_url: 'http://somedomain.com/pinterest'
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
    post settings_mails_webicons_path, params:
      {
        webicon: fixture_file_upload('settings/webicon-youtube.png', 'image/png'),
        social: 'pinterest',
        social_url: 'http://somedomain.com/pinterest'
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
  end

  test 'authenticated super_admin cannot upload mails webicon with wrong type' do
    sign_in users(:superadmin)
    post settings_mails_webicons_path, params:
      {
        webicon: fixture_file_upload('settings/badge_black.jpg', 'image/jpeg'),
        social: 'twitter',
        social_url: 'http://somedomain.com/twitter'
      }
    assert_equal I18n.t('settings.notices.type_error'), flash[:alert]
  end

  test 'authenticated super_admin cannot upload mails webicon without image' do
    sign_in users(:superadmin)
    post settings_mails_webicons_path, params:
      {
        social: 'twitter',
        social_url: 'http://somedomain.com/twitter'
      }
    assert_equal I18n.t('settings.notices.missing_image_error'), flash[:alert]
  end

  test 'authenticated super_admin cannot upload mails webicon without social' do
    sign_in users(:superadmin)
    post settings_mails_webicons_path, params:
      {
        webicon: fixture_file_upload('settings/webicon-twitter.png', 'image/png'),
        social_url: 'http://somedomain.com/twitter'
      }
    assert_equal I18n.t('settings.notices.filename_error'), flash[:alert]
  end

  test 'authenticated super_admin cannot upload mails webicon without social url' do
    sign_in users(:superadmin)
    post settings_mails_webicons_path, params:
      {
        webicon: fixture_file_upload('settings/webicon-twitter.png', 'image/png'),
        social: 'twitter'
      }
    assert_equal I18n.t('settings.notices.missing_image_error'), flash[:alert]
  end

  test 'unauthenticated cannot upload mails webicon' do
    post settings_mails_webicons_path, params:
      {
        webicon: fixture_file_upload('settings/webicon-twitter.png', 'image/png'),
        social: 'twitter',
        social_url: 'http://somedomain.com/twitter'
      }
    check_not_authenticated
  end

  #### THUMBNAILS

  test 'authenticated super_admin only can upload thumbnail image' do
    sign_in users(:staffuser)
    post settings_wsc_thumbs_path, params:
      {
        thumbnail: fixture_file_upload('settings/WSC_full.png', 'image/png'),
        size: 'full'
      }
    check_not_authorized
    sign_in users(:superadmin)
    post settings_wsc_thumbs_path, params:
      {
        thumbnail: fixture_file_upload('settings/WSC_full.png', 'image/png'),
        size: 'full'
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
  end

  test 'authenticated super_admin cannot upload thumbnail image with wrong type' do
    sign_in users(:superadmin)
    post settings_wsc_thumbs_path, params:
      {
        thumbnail: fixture_file_upload('settings/WSC_full.jpg', 'image/jpeg'),
        size: 'full'
      }
    assert_equal I18n.t('settings.notices.type_error'), flash[:alert]
  end

  test 'authenticated super_admin cannot upload thumbnail image without image' do
    sign_in users(:superadmin)
    post settings_wsc_thumbs_path, params:
      {
        size: 'full'
      }
    assert_equal I18n.t('settings.notices.missing_image_error'), flash[:alert]
  end

  test 'authenticated super_admin cannot upload thumbnail image without complete name' do
    sign_in users(:superadmin)
    post settings_wsc_thumbs_path, params:
      {
        thumbnail: fixture_file_upload('settings/WSC_full.png', 'image/png')
      }
    assert_equal I18n.t('settings.notices.filename_error'), flash[:alert]
  end

  test 'unauthenticated cannot upload thumbnail image' do
    post settings_wsc_thumbs_path, params:
      {
        thumbnail: fixture_file_upload('settings/WSC_full.png', 'image/png'),
        size: 'full'
      }
    check_not_authenticated
  end

  #### BLAZONS = MEDALS = BADGES

  test 'authenticated super_admin only can upload badge image' do
    sign_in users(:staffuser)
    post settings_badges_path, params:
      {
        badge: fixture_file_upload('settings/badge_black.png', 'image/png'),
        level: 'black'
      }
    check_not_authorized
    sign_in users(:superadmin)
    post settings_badges_path, params:
      {
        badge: fixture_file_upload('settings/badge_black.png', 'image/png'),
        level: 'black'
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
  end

  test 'authenticated super_admin can upload badge images for each level' do
    sign_in users(:superadmin)
    post settings_badges_path, params:
      {
        badge: fixture_file_upload('settings/badge_black.png', 'image/png'),
        level: 'black'
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
    post settings_badges_path, params:
      {
        badge: fixture_file_upload('settings/badge_bronze.png', 'image/png'),
        level: 'bronze'
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
    post settings_badges_path, params:
      {
        badge: fixture_file_upload('settings/badge_silver.png', 'image/png'),
        level: 'silver'
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
    post settings_badges_path, params:
      {
        badge: fixture_file_upload('settings/badge_gold.png', 'image/png'),
        level: 'gold'
      }
    assert_equal I18n.t('settings.notices.success'), flash[:notice]
  end

  test 'authenticated super_admin cannot upload badge image with wrong type' do
    sign_in users(:superadmin)
    post settings_badges_path, params:
      {
        badge: fixture_file_upload('settings/badge_black.jpg', 'image/jpeg'),
        level: 'black'
      }
    assert_equal I18n.t('settings.notices.type_error'), flash[:alert]
  end

  test 'authenticated super_admin cannot upload badge image without image' do
    sign_in users(:superadmin)
    post settings_badges_path, params:
      {
        level: 'black'
      }
    assert_equal I18n.t('settings.notices.missing_image_error'), flash[:alert]
  end

  test 'authenticated super_admin cannot upload badge image without complete name' do
    sign_in users(:superadmin)
    post settings_badges_path, params:
      {
        badge: fixture_file_upload('settings/badge_black.png', 'image/png')
      }
    assert_equal I18n.t('settings.notices.filename_error'), flash[:alert]
  end

  test 'unauthenticated cannot upload badge image' do
    post settings_badges_path, params:
      {
        badge: fixture_file_upload('settings/badge_black.png', 'image/png'),
        level: 'black'
      }
    check_not_authenticated
  end

  ### CERTIFICATES AND STATISTICS

  test 'authenticated super_admin only can update certificates and statistics' do
    sign_in users(:staffuser)
    put settings_stats_path, params: {}
    check_not_authorized
    sign_in users(:superadmin)
    put settings_stats_path, params: {}
    assert_equal I18n.t('settings.notices.updated'), flash[:notice]
  end

  test 'unauthenticated cannot update certificates and statistics' do
    put settings_stats_path, params: {}
    check_not_authenticated
  end

  test 'authenticated super_admin only can update all certificates and statistics' do
    p = Project.first
    p.statistics.destroy!
    assert Project.find(p.id).statistics.nil?
    p.certificate.destroy!
    assert Project.find(p.id).certificate.nil?
    sign_in users(:staffuser)
    put settings_stats_path
    check_not_authorized
    sign_in users(:superadmin)
    put settings_stats_path
    assert Project.find(p.id).statistics.present?
    assert Project.find(p.id).certificate.present?
  end

  test 'unauthenticated cannot access resque_server_path' do
    get resque_server_path
    assert_redirected_to 'http://www.example.com/users/sign_in'
  end

  test 'authenticated staff super_admin only can access to resque_server_path' do
    sign_in users(:c_one)
    assert_raises ActionController::RoutingError do
      get resque_server_path
    end
    delete logout_path
    sign_in users(:staffuser)
    assert_raises ActionController::RoutingError do
      get resque_server_path
    end
    delete logout_path
    sign_in users(:superadmin)
    get resque_server_path
    assert_redirected_to 'http://www.example.com/debug/jobs/overview'
  end
end
