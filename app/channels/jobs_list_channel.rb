# frozen_string_literal: true

class JobsListChannel < ApplicationCable::Channel
  # Called when the consumer has successfully
  # become a subscriber to this channel.
  def subscribed
    stream_or_reject_for current_user
  end

  def unsubscribed
    stop_all_streams
  end
end
