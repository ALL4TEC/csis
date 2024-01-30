# frozen_string_literal: true

require 'application_system_test_case'

class ReportsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  # J'étais parti pour faire des tests systèmes mais ils ne se lancent pas
  # sur ma machine locale. T

  # test 'when selecting VmScan IPs are also selected' do
  # staff = users(:staffuser)
  # I18n.locale = staff.language.iso
  # sign_in staff
  # r = reports(:one)
  # visit report_path(r)
  # click_on r.title
  # end

  # test 'when deselecting VmScan IPs are also deselected' do
  # staff = users(:staffuser)
  # I18n.locale = staff.language.iso
  # sign_in staff
  # r = reports(:one)
  # visit report_path(r)
  # click_on r.title
  # end
end
