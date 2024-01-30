# frozen_string_literal: true

class MicrosoftTeamsConfigPolicy < ChatConfigPolicy
  def permitted_attributes
    [:channel_name, :url, { user_ids: [] }]
  end
end
