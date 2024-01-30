# frozen_string_literal: true

class JiraConfigExt < ApplicationRecord
  include EnumSelect

  self.table_name = :jira_configs

  belongs_to :jira_config, inverse_of: :ext

  # order matters: goal is that when sorting by the "status" field,
  # quickly fixable configs come first
  enum_with_select :status, {
    request: 0, # first so the user can see he has >10 minutes left to accept the request
    project_not_found: 1, # second because it should be a quick fix for the user
    ko: 2, # third because it can be a lot of things and may be long to fix
    expire_soon: 3, # less urgent than the others
    ok: 4
  }, _suffix: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[context created_at expiration_date id jira_config_id project_id status updated_at]
  end
end
