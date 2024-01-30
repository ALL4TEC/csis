# frozen_string_literal: true

module ApiAuthAccount
  extend ActiveSupport::Concern
  include ApiAccount

  included do
    cleared_attr_encrypted :secret_key, key: Rails.application.credentials.key
  end
end
