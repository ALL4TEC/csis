# frozen_string_literal: true

class ScanConfigurationParamsHandler
  attr_reader :params, :entity, :policy, :linked_entity

  def initialize(params, entity, policy, linked_entity)
    @params = params
    @entity = entity
    @policy = policy
    @linked_entity = linked_entity
  end

  def self.call(params, entity, policy, linked_entity)
    new(params, entity, policy, linked_entity).build
  end

  def build
    scanner = @params[:action].to_sym
    permitted = check_params
    permitted_scan_conf = permitted[:scan_configuration_attributes]
    target = permitted_scan_conf[:target]
    scan_type = permitted_scan_conf[:scan_type]
    scan_name = permitted_scan_conf[:scan_name]
    parameters = permitted_scan_conf[:parameters]
    auto_import = permitted_scan_conf[:auto_import]
    auto_aggregate = permitted_scan_conf[:auto_aggregate]
    auto_aggregate_mixing = permitted_scan_conf[:auto_aggregate_mixing]
    if scheduled_scan?
      scheduled_scan_cron = permitted[:scheduled_scan_cron]
      report_action = permitted[:report_action]
    end

    scan_type_ok = scan_type.in?(ScanConfiguration::SCANNERS_DATA[scanner][:scan_types].values)
    cleaned_params = parameters.compact_blank
    parameters_ok = cleaned_params.all? do |param|
      param.to_sym.in?(ScanConfiguration::SCANNERS_DATA[scanner][:options].keys)
    end

    return raise ActiveRecord::RecordNotFound unless scan_type_ok && parameters_ok

    hash = {
      launcher: policy.user,
      scanner: scanner,
      scan_type: scan_type,
      scan_name: scan_name,
      target: target,
      parameters: cleaned_params.join(' '),
      auto_import: auto_import,
      auto_aggregate: auto_aggregate,
      auto_aggregate_mixing: auto_aggregate_mixing
    }
    args = if scheduled_scan?
             {
               scheduled_scan_cron: scheduled_scan_cron,
               report_action: report_action
             }
           else
             {}
           end
    scan_configuration = ScanConfiguration.create(hash)
    send(:"build_#{entity}", scan_configuration, args)
  end

  private

  def build_scheduled_scan(scan_configuration, args)
    ScheduledScan.new(
      scan_configuration: scan_configuration,
      scheduled_scan_cron: args[:scheduled_scan_cron],
      report_action: args[:report_action],
      project: @linked_entity
    )
  end

  def build_scan_launch(scan_configuration, _args)
    ScanLaunch.new(
      scan_configuration: scan_configuration,
      report: @linked_entity
    )
  end

  def check_params
    @params.require(@entity)
           .permit(@policy.permitted_attributes)
  end

  def scheduled_scan?
    @entity == :scheduled_scan
  end
end
