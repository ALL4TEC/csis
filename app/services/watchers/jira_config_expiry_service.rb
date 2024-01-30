# frozen_string_literal: true

module Watchers
  class JiraConfigExpiryService
    class << self
      def check_statuses
        JiraConfig.all.find_each do |config|
          # these checks are useless if config is already KO
          next unless config.status != 'ko'

          offline_checks config
          next unless Rails.application.config.pmt_checker_internet

          online_checks config
        end
      end

      private

      # Checks without calling external API (only using config.expiration_date)
      def offline_checks(config)
        if JiraConfigPredicate.expired?(config)
          config.update(status: :ko)
        elsif JiraConfigPredicate.expires_soon?(config)
          # change status only if everything was ok
          # (i.e. not :request, :project_not_found or :expire_soon)
          config.update(status: :expire_soon) if config.status == 'ok'
        end
      end

      # Checks which require external API access (server and project access)
      def online_checks(config)
        wrapper = Jira::Wrapper.new(config)
        wrapper.set_auth_token
        config.update(status: :ko) unless wrapper.server_reachable?
        config.update(status: :project_not_found) unless wrapper.project_exists?
      end
    end
  end
end
