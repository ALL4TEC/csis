# frozen_string_literal: true

module RemediationPolicy
  extend ActiveSupport::Concern

  included do
    def index?
      staff? || contact?
    end

    def show?
      staff? || contact?
    end

    def admin?
      contact_admin? || administrator?
    end
  end
end
