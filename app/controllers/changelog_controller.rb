# frozen_string_literal: true

class ChangelogController < ApplicationController
  before_action :authenticate_user_no_redir!

  def history
    if ChangelogPolicy.new(current_user, nil).history?
      render json: { html: render_to_string(partial: 'changelog/history') }
    else
      render json: :error
    end
  end
end
