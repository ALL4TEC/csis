# frozen_string_literal: true

class SlackConfigPolicy < ChatConfigPolicy
  def oauth?
    super_admin?
  end

  def permitted_attributes
    [:name, :external_application_id, :workspace_name, :channel_name, :channel_id,
     { user_ids: [] }]
  end
end
