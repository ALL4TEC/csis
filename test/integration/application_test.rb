# frozen_string_literal: true

require 'test_helper'

class ApplicationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # En imaginant que l'on puisse changer la langue sur la page de login
  test 'unauthenticated can change locale with param' do
    change_locale
  end

  test 'unauthenticated can change locale without param' do
    change_locale(nil)
  end

  test 'authenticated staff can change locale with param' do
    change_locale_staff
  end

  test 'authenticated staff can change locale without param' do
    change_locale_staff(nil)
  end

  test 'authenticated contact can change locale with param' do
    change_locale_contact
  end

  test 'authenticated contact can change locale without param' do
    change_locale_contact(nil)
  end

  private

  def change_locale_staff(locale = :en)
    sign_in users(:staffuser)
    change_locale(locale)
  end

  def change_locale_contact(locale = :en)
    sign_in users(:c_one)
    change_locale(locale)
  end

  def change_locale(locale = :en)
    params = locale.present? ? { locale: locale } : {}
    post dashboard_locale_path, params: params
    assert_response 302
  end
end
