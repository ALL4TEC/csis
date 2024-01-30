# frozen_string_literal: true

class ServicenowConfigExt < ApplicationRecord
  include EnumSelect

  self.table_name = :servicenow_configs

  belongs_to :servicenow_config, inverse_of: :ext

  enum_with_select :status, {
    ko: 0,
    ok: 1
  }, suffix: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id need_refresh_at servicenow_config_id status fixed_vuln accepted_risk
       updated_at]
  end
end
