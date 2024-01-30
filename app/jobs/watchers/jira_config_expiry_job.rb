# frozen_string_literal: true

# This job checks for expired (or soon to be) JiraConfigs
# called by Rake task pmt:check_config_status
class Watchers::JiraConfigExpiryJob < ApplicationKubeJob
  def perform
    Watchers::JiraConfigExpiryService.check_statuses
  end
end
