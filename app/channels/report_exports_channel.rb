# frozen_string_literal: true

class ReportExportsChannel < ApplicationCable::Channel
  def subscribed
    stream_or_reject_for ReportExport.find(params[:id])
  end

  def unsubscribed
    stop_all_streams
  end
end
