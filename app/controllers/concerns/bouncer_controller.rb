# frozen_string_literal: true

module BouncerController
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :authorize!
    before_action :set_whodunnit
  end
end
