# frozen_string_literal: true

module FakeSlack
  class ConversationsListResponse
    attr_reader :json

    def initialize(file_name)
      @file_name = file_name
      @json = JSON.parse(
        File.read("test/fixtures/files/slack/#{file_name}.json")
      )
    end

    def [](key)
      @json[key]
    end

    def channels
      @json['channels'].map { |channel_data| FakeSlack::Channel.new(channel_data) }
    end
  end

  class Channel
    attr_reader :json, :name, :id

    def initialize(json)
      @json = json
      @name = json['name']
      @id = json['id']
    end

    def [](key)
      @json[key]
    end
  end
end
