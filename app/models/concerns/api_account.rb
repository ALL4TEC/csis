# frozen_string_literal: true

module ApiAccount
  extend ActiveSupport::Concern
  include ClearedAttrEncryptedConcern

  included do
    cleared_attr_encrypted :api_key, key: Rails.application.credentials.key
  end
end
