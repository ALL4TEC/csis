# frozen_string_literal: true

class ChatConfig < Account
  include ApiAccount

  TYPES = {
    google_chat_config: :workspace_name,
    microsoft_teams_config: :channel_name,
    slack_config: :bot_user_id,
    zoho_cliq_config: :bot_name
  }.freeze

  belongs_to :chat_application,
    class_name: 'ChatApplication',
    inverse_of: :chat_configs,
    primary_key: :id,
    foreign_key: :external_application_id,
    optional: true

  has_one :ext,
    class_name: 'ChatConfigExt',
    inverse_of: :chat_config,
    primary_key: :id,
    dependent: :destroy,
    autosave: true

  delegate :bot_user_id, :bot_user_id=, to: :lazily_built_ext
  delegate :bot_name, :bot_name=, to: :lazily_built_ext
  delegate :webhook_domain, :webhook_domain=, to: :lazily_built_ext
  delegate :channel_id, :channel_id=, to: :lazily_built_ext
  delegate :channel_name, :channel_name=, to: :lazily_built_ext
  delegate :workspace_name, :workspace_name=, to: :lazily_built_ext

  validates :url, presence: true, on: :create

  scope :google_chat_configs, -> { where(type: 'GoogleChatConfig') }
  scope :microsoft_teams_configs, -> { where(type: 'MicrosoftTeamsConfig') }
  scope :slack_configs, -> { where(type: 'SlackConfig') }
  scope :zoho_cliq_configs, -> { where(type: 'ZohoCliqConfig') }

  def to_s
    "#{name} (#{TYPES[type]})"
  end

  def self.all_types
    TYPES.keys.map { |k| k.to_s.camelize }
  end

  def self.first_enabled_type
    TYPES.keys.find do |k|
      Rails.application.config.send(:"#{k.to_s.delete_suffix('_config')}_enabled")
    end
  end

  private

  def lazily_built_ext
    ext || build_ext
  end
end
