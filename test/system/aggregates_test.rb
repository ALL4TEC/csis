# frozen_string_literal: true

require 'application_system_test_case'

class AggregatesTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'authenticated staff can delete existent aggregate' do
    staff = users(:staffuser)
    I18n.with_locale(staff.language.iso) do
      sign_in staff
      a = aggregates(:one)
      visit aggregate_path(a)
      click_on I18n.t('aggregates.actions.destroy')
      assert_raises ActiveRecord::RecordNotFound do
        a = Aggregate.find(a.id)
      end
    end
  end
end
