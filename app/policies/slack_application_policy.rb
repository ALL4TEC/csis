# frozen_string_literal: true

class SlackApplicationPolicy < ChatConfigPolicy
  def permitted_attributes
    %i[name app_id client_id client_secret signing_secret]
  end
end
