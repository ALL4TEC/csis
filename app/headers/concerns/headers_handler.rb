# frozen_string_literal: true

require 'concerns/icons'

class HeadersHandler
  include Rails.application.routes.url_helpers

  DEFAULT_ACTIONS = {
    back: {
      label: 'section_header.actions.back',
      href: 'data',
      icon: Icons::MAT[:back]
    }
  }.freeze

  # Initializer variable is a hash following Inuit::SectionHeader convention
  def initialize(tabs = {}, actions = {})
    @tabs = tabs
    @actions = DEFAULT_ACTIONS.merge(actions)
  end

  # Construit un tab (anciennement scope) à partir de la map d'initialisation
  # en allant chercher la clef sym, en remplaçant la variable data de la map
  # par les data fournies
  # Si badge on évalue la traduction du subtitle en injectant le count du badge
  # Sinon on translate simplement le subtitle
  def tab(sym, _data)
    selected_tab = @tabs[sym]
    tab_h = {
      label: I18n.t(selected_tab[:label]),
      href: instance_eval(selected_tab[:href])
    }
    tab_h[:badge] = instance_eval(selected_tab[:badge]) if selected_tab[:badge].present?
    if selected_tab[:subtitle].present?
      count = instance_eval(selected_tab[:badge].presence.to_s)
      tab_h[:subtitle] = I18n.t(selected_tab[:subtitle], count: count)
    end
    tab_h[:icon] = selected_tab[:icon] if selected_tab[:icon].present?
    tab_h[:logo] = selected_tab[:logo] if selected_tab[:logo].present?
    tab_h
  end

  # Call tab for each element of tabs_array
  # Which means each element of tabs_array contains all args needed by one tab
  # Prefer using tabs when possible
  def tabs_a(tabs_array)
    tabs_ary = []
    tabs_array.each do |array_element|
      tabs_ary << tab(
        array_element[0],
        array_element[1]
      )
    end
    tabs_ary
  end

  # Call tab for each element of syms_array associating data and count if present
  # which means @param syms_array contains all tabs symbols,
  # @param tada contains data which will be applied to each tab
  def tabs(syms_array, tada)
    tabs_ary = []
    syms_array.each do |sym|
      tabs_ary << tab(sym, tada)
    end
    tabs_ary
  end

  # Build an action from @actions[:sym] evaluating data when needed + set infos if present?
  # Infos is used in _confirm translations and thus must be used as the inline variable
  # Ex: destroy_confirm: "Are you sure you want to delete the Qualys configuration %{infos}?"
  # @return an action hash containing label, href, icon, method and data if confirm present
  def action(sym, data, infos = nil)
    selected_action = @actions[sym]
    action_h = {
      label: I18n.t(selected_action[:label]),
      href: instance_eval(selected_action[:href])
    }
    action_h[:method] = selected_action[:method] if selected_action[:method].present?
    if selected_action[:confirm].present?
      infos ||= data.to_s
      action_h[:data] = { confirm: I18n.t(selected_action[:confirm], infos: infos) }
    end
    action_h[:icon] = selected_action[:icon] if selected_action[:icon].present?
    action_h[:logo] = selected_action[:logo] if selected_action[:logo].present?
    action_h
  end

  # Call action for each element of actions_array
  # Which means each element of actions_array contains all args needed by one action
  # Prefer using actions when possible
  # @return an array containg each action data
  def actions_a(actions_array)
    actions_ary = []
    actions_array.each do |array_element|
      actions_ary << action(
        array_element[0],
        array_element[1],
        array_element[2].presence
      )
    end
    actions_ary
  end

  # Call action for each element of syms_array associating data and infos if present
  # which means @param syms_array contains all actions symbols,
  # @param tada contains data which will be applied to each action
  # @param infos contains special infos which will be applied to each action containing 'confirm'
  # @return an array containing each action data
  def actions(syms_array, tada, infos = nil)
    actions_ary = []
    syms_array.each do |sym|
      actions_ary << action(sym, tada, infos)
    end
    actions_ary
  end

  private

  # @param **clazzs:** Pluralized clazz
  # @param **clazz:** Clazz name
  # @param **name:** Header symbol
  # @param **data:** Optional data to override default
  # @return the hash corresponding to name action
  def build_h(clazzs, clazz, name, data = {})
    {
      label: data.fetch(:label, "#{clazzs}.actions.#{name}"),
      href: data.fetch(:href, "#{name}_#{clazz}_path(data)"),
      method: data.fetch(:method, :put),
      icon: data.fetch(:icon, Icons::MAT[name])
    }
  end
end
