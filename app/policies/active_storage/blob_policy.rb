# frozen_string_literal: true

module ActiveStorage
  class BlobPolicy < ApplicationPolicy
    def show?
      # @blob.attachments.map(&:record).all? { |record| record.user == current_user }
      if @record.attachments.present?
        @record.attachments.map(&:record).any? do |record|
          # policy_scope(record.class).find(record)
          scope = instance_eval("#{record.class}Policy::Scope", __FILE__, __LINE__) # Rubocop
          scope.new(@user, record.class).resolve.find(record.id)
        end
      else
        true
      end
    end
  end
end
