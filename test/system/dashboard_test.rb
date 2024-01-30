# frozen_string_literal: true

require 'application_system_test_case'

class DashboardTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'authenticated user can sign out' do
    staff = users(:staffuser)
    I18n.with_locale(staff.language.iso) do
      sign_in staff
      visit dashboard_url
      click_link I18n.t('sign_out')
      assert has_current_path?(new_user_session_path)
    end
  end
end
