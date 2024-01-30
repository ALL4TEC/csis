# frozen_string_literal: true

class ChatApplication < ExternalApplication
  has_many :chat_configs,
    class_name: 'ChatConfig',
    inverse_of: :chat_application,
    primary_key: :id,
    foreign_key: :external_application_id,
    dependent: :destroy
end
