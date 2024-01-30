# frozen_string_literal: true

module CyberPolicy
  extend ActiveSupport::Concern

  included do
    def index?
      staff?
    end

    def show?
      staff?
    end

    def admin?
      cyber_admin? || administrator?
    end
  end
end
