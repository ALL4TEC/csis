# frozen_string_literal: true

class JobsChannel < ApplicationCable::Channel
  def subscribed
    stream_or_reject_for Job.find(params[:id])
  end

  def unsubscribed
    stop_all_streams
  end
end
