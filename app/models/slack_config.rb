# frozen_string_literal: true

class SlackConfig < ChatConfig
  include ApiAccount

  def set_type
    self.type = 'SlackConfig'
  end

  belongs_to :slack_application,
    class_name: 'SlackApplication',
    inverse_of: :slack_configs,
    primary_key: :id,
    foreign_key: :external_application_id,
    optional: true

  has_one :ext,
    class_name: 'ChatConfigExt',
    inverse_of: :chat_config,
    foreign_key: :chat_config_id,
    dependent: :destroy,
    autosave: true

  def to_s
    "#{name}: #{bot_user_id}"
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[app_id id name type]
  end
end
