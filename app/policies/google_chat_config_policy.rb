# frozen_string_literal: true

class GoogleChatConfigPolicy < ChatConfigPolicy
  def permitted_attributes
    [:workspace_name, :url, { user_ids: [] }]
  end
end
