# frozen_string_literal: true

class Users::TwoFactorAuthenticationController < Devise::TwoFactorAuthenticationController
  layout 'unauthenticated'
end
