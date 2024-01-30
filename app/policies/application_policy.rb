# frozen_string_literal: true

class ApplicationPolicy < PolicyConcern
  attr_reader :record

  def initialize(user, record)
    super(user)
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def new?
    false
  end

  def create?
    new?
  end

  def edit?
    false
  end

  def update?
    edit?
  end

  def destroy?
    false
  end

  def restore?
    false
  end

  def self?
    @record.id == @user.id
  end

  class Scope < PolicyConcern
    attr_reader :scope

    def initialize(user, scope)
      super(user)
      @scope = scope
    end

    def resolve
      if staff?
        scope.all
      elsif contact?
        scope.for_contact
      else
        scope.none
      end
    end
  end

  class Headers < PolicyConcern
    attr_reader :kind, :record

    # @param **user:** current_user
    # @param **kind:** 'member' or 'collection'
    # @param **record:** Used by self?
    # @param **policy:** Used by filter_available
    def initialize(user, kind, record = nil, policy = nil)
      super(user)
      @kind = kind
      @record = record
      if policy.blank?
        policy = self.class.name.delete_suffix('::Headers')
        @policy = instance_eval(policy, __FILE__, __LINE__).new(@user, @record)
      else
        @policy = policy
      end
    end

    def actions
      send(:"#{kind}_actions")
    end

    def other_actions
      send(:"#{kind}_other_actions")
    end

    def tabs
      send(:"#{kind}_tabs")
    end

    # Filter actions, other_actions and tabs allowed for user
    def filter
      { actions: actions, other_actions: other_actions, tabs: tabs }
    end

    def self?
      @record&.id == @user.id
    end

    private

    # Select only allowed methods by @policy
    def filter_available(actions_ary)
      actions_ary.select { |method| @policy.send(:"#{method}?") }
    end
  end
end
