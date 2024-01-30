# frozen_string_literal: true

class CyberwatchConfigsParamsHandler < ConfigsParamsHandler
  AVAILABLE_METHODS = %i[date name].freeze
  CREATED_AT_1I = 'created_at(1i)'
  CREATED_AT_2I = 'created_at(2i)'
  CREATED_AT_3I = 'created_at(3i)'

  def self.call(permitted, controller_action)
    new(permitted, controller_action, AVAILABLE_METHODS).handle
  end

  private

  # HANDLERS
  def handle_date
    if [permitted[CREATED_AT_1I],
        permitted[CREATED_AT_2I],
        permitted[CREATED_AT_3I]].all?(&:present?)
      year = permitted[CREATED_AT_1I].to_i
      month = permitted[CREATED_AT_2I].to_i
      day = permitted[CREATED_AT_3I].to_i
      Date.new(year, month, day).to_s
    end
  end

  # VM
  def handle_scans_date
    date = handle_date
    @opts[:launched_after_datetime] = date if date.present?
  end

  def handle_scans_name
    @opts[:scan_ref] = permitted[:name] if permitted[:name].present?
  end
end
