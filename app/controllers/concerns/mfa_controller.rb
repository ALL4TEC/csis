# frozen_string_literal: true

module MfaController
  extend ActiveSupport::Concern

  included do |_base|
    # Authentication is left to child controller
    before_action :set_mfa_resource, only: %i[force_mfa unforce_mfa]
    before_action :authorize_mfa_resource!, only: %i[force_mfa unforce_mfa]

    # PUT /resources/:id/force_mfa
    def force_mfa
      @resource.update!(otp_mandatory: true)
      redirect_to(back_in_history)
    end

    # PUT /resources/:id/unforce_mfa
    def unforce_mfa
      @resource.update!(otp_mandatory: false)
      redirect_to(back_in_history)
    end

    private

    def set_mfa_resource
      clazz = instance_eval(
        self.class.name.delete_suffix('Controller').singularize, __FILE__, __LINE__
      )
      handle_unscoped do
        @resource = policy_scope(clazz).find(params[:id])
      end
    end

    def authorize_mfa_resource!
      authorize(@resource)
    end
  end
end
