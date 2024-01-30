# frozen_string_literal: true

class ChatConfigsController < ApplicationController
  NAME_ASC = ['name asc'].freeze

  # GET /chat_configs
  # Redirect to first tab corresponding to first active chat config among availables
  # and enabled
  def index
    redirect_to "/#{Configs::ChatConfigService.any_enabled_type}s"
  end
end
