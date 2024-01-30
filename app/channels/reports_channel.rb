# frozen_string_literal: true

class ReportsChannel < ApplicationCable::Channel
  def subscribed
    stream_or_reject_for Report.find(params[:id])
  end

  def unsubscribed
    stop_all_streams
  end
end
