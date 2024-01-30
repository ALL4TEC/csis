# frozen_string_literal: true

class OauthService
  class << self
    def generate_slack_state(slack_application, current_user)
      "#{slack_application.id}:#{current_user.id}"
    end
  end
end
