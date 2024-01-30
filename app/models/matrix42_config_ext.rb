# frozen_string_literal: true

class Matrix42ConfigExt < ApplicationRecord
  include EnumSelect

  self.table_name = :matrix42_configs

  belongs_to :matrix42_config, inverse_of: :ext

  enum_with_select :status, {
    url_ko: 0,
    auth_ko: 1,
    ok: 2
  }, suffix: true

  enum_with_select :default_ticket_type, {
    ticket: 0,
    incident: 1,
    service_request: 2
  }, suffix: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id need_refresh_at matrix42_config_id status fixed_vuln accepted_risk
       updated_at]
  end
end
