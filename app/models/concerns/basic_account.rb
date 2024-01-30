# frozen_string_literal: true

module BasicAccount
  extend ActiveSupport::Concern
  include ClearedAttrEncryptedConcern

  included do
    cleared_attr_encrypted :login, key: Rails.application.credentials.key
    cleared_attr_encrypted :password, key: Rails.application.credentials.key
  end
end
