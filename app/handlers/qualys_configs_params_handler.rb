# frozen_string_literal: true

class QualysConfigsParamsHandler < ConfigsParamsHandler
  AVAILABLE_METHODS = %i[date name clients].freeze
  SINCE = 'created_at'

  def self.call(permitted, controller_action)
    new(permitted, controller_action, AVAILABLE_METHODS).handle
  end

  private

  # HANDLERS
  def handle_date
    permitted[SINCE]
  end

  # VM
  def handle_vm_date
    date = handle_date
    @opts[:launched_after_datetime] = date if date.present?
  end

  # @return empty string if all in qvc else qvc
  def handle_present_vm_clients(qvc)
    @opts[:client_ids] = qvc.any?('all') ? '' : qvc
  end

  def handle_vm_clients
    qvc = permitted[:qualys_vm_client_ids]
    handle_present_vm_clients(qvc.compact_blank) if qvc.present?
  end

  def handle_vm_name
    @opts[:scan_ref] = permitted[:name] if permitted[:name].present?
  end

  # WA
  def handle_wa_date
    date = handle_date
    @opts[:launched_date] = date if date.present?
  end

  # @return empty string if all in qwc else qwc.flat_map(&:to_s).join(',')
  def handle_present_wa_clients(qwc)
    @opts[:'webApp.tags.id'] = qwc.any?('all') ? '' : qwc.flat_map(&:to_s).join(',')
  end

  def handle_wa_clients
    qwci = permitted[:qualys_wa_client_ids]
    handle_present_wa_clients(qwci.compact_blank) if qwci.present?
  end

  def handle_wa_name
    @opts[:name] = permitted[:name] if permitted[:name].present?
  end
end
