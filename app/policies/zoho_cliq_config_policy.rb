# frozen_string_literal: true

class ZohoCliqConfigPolicy < ChatConfigPolicy
  def permitted_attributes
    [:bot_name, :webhook_domain, :api_key, { user_ids: [] }]
  end
end
