# frozen_string_literal: true

class WhoisController < ApplicationController
  before_action :authenticate_user_no_redir!
  before_action :authorize!

  def whois
    render json: {
      title: "WHOIS #{params[:target]}",
      html: render_to_string(
        partial: 'partials/whois', locals: { content: format_whois(params[:target]) }
      )
    }
  end

  private

  def authorize!
    authorize(:whois)
  end

  def format_whois(target)
    record = Whois.whois(target)
    encoded = record.to_s.force_encoding('UTF-8')
    formatted = encoded.split("\n").map do |line|
      if line.start_with?('#', '%')
        line.insert(0, "<span class='text-muted'>")
        line << '</span><br>'
      elsif (index = line.index(':')).present?
        line.insert(index + 1, '</b>')
        line.insert(0, '<b>')
        line << '<br>'
      else
        line << '<br>'
      end
      line
    end
    formatted.join
  rescue StandardError => e
    e.message.presence
  end
end
