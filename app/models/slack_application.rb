# frozen_string_literal: true

class SlackApplication < ChatApplication
  # Ransack
  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[app_id id name type]
    end

    def ransackable_associations(_auth_object = nil)
      %w[accounts chat_configs slack_configs versions]
    end
  end

  has_many :slack_configs,
    class_name: 'SlackConfig',
    inverse_of: :slack_application,
    primary_key: :id,
    foreign_key: :external_application_id,
    dependent: :destroy
end
