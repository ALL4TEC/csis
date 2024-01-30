# frozen_string_literal: true

class ChatConfigExt < ApplicationRecord
  self.table_name = :chat_configs

  belongs_to :chat_config,
    class_name: 'ChatConfig',
    primary_key: :id,
    inverse_of: :ext
end
