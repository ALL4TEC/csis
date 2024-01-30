# frozen_string_literal: true

class ChatConfigPolicy < SuperAdminPolicy
  def google_chat_configs?
    super_admin?
  end

  def microsoft_teams_configs?
    super_admin?
  end

  def slack_configs?
    super_admin?
  end

  def zoho_cliq_configs?
    super_admin?
  end

  # To be overriden by each chat provider
  class Scope < ApplicationPolicy::Scope
    def resolve
      super_admin? ? scope.all : scope.none
    end
  end

  class Headers < ApplicationPolicy::Headers
    private

    def list_tabs
      filter_available(
        %i[google_chat_configs microsoft_teams_configs slack_configs zoho_cliq_configs]
      )
    end
  end
end
