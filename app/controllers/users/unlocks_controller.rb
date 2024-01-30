# frozen_string_literal: true

class Users::UnlocksController < Devise::ConfirmationsController
  def new
    raise Pundit::NotAuthorizedError
  end

  def create
    raise Pundit::NotAuthorizedError
  end
end
