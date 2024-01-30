# frozen_string_literal: true

class SellsyConfigPolicy < SuperAdminPolicy
  def permitted_attributes
    %i[name consumer_token user_token consumer_secret user_secret]
  end

  def import?
    super_admin?
  end
end
