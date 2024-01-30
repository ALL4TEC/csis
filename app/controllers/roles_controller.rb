# frozen_string_literal: true

class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_whodunnit

  include MfaController
end
