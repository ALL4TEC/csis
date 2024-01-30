# frozen_string_literal: true

class ConfigsParamsHandler
  FORM_ERROR = 'Form Error'

  attr_reader :permitted, :kind, :action, :available_methods_ary

  def initialize(permitted, controller_action, available_methods_ary)
    @permitted = permitted
    action_ary = controller_action.split('_')
    @kind = action_ary.first
    @action = action_ary.last
    @available_methods_ary = available_methods_ary
    @opts = {}
  end

  def available_methods
    available = @available_methods_ary
    available = available.reject { |methode| methode == :name } if @action == 'update'
    available
  end

  def handle
    available_methods.each { |method_name| send(:"handle_#{@kind}_#{method_name}") }
    @opts
  end
end
