# frozen_string_literal: true

# Create, Restore, Edit, Delete policy
class CredPolicy < ApplicationPolicy
  class Headers < ApplicationPolicy::Headers
    private

    def collection_actions
      filter_available(%i[create])
    end

    def member_actions
      filter_available(%i[restore edit])
    end

    def member_other_actions
      filter_available(%i[destroy])
    end
  end
end
