# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module ScannerConfigScheduler
  extend ActiveSupport::Concern

  included do
    # used to store cron created before id is available...
    attr_accessor :tmp_vm_import_cron
    attr_accessor :tmp_wa_import_cron

    def vm_import_cron
      import_cron(:vm)
    end

    def wa_import_cron
      import_cron(:wa)
    end

    def vm_import_cron=(value)
      send(:import_cron=, :vm, value)
    end

    def wa_import_cron=(value)
      send(:import_cron=, :wa, value)
    end

    def import_cron=(accro, value)
      cron_data = {
        cronable_id: id,
        cronable_type: 'Account',
        name: import_schedule_name(accro)
      }
      send(:"tmp_#{accro}_import_cron=", Cron.find_or_create_by(cron_data))
      send(:"tmp_#{accro}_import_cron").update!(value: value)
    end

    def print_class
      self.class
    end

    private

    def import_cron_not_nil?(accro)
      return true unless send(:"tmp_#{accro}_import_cron").nil?

      errors.add(:"#{accro}_import_cron", 'must be present !')
    end

    def import_crons_presence
      KindUtil.scan_accros.each do |accro|
        import_cron_not_nil?(accro)
      end
    end

    def vm_import_cron_presence
      import_cron_not_nil?('vm')
    end

    def wa_import_cron_presence
      import_cron_not_nil?('wa')
    end

    def import_cron(accro)
      crons.find_by(name: import_schedule_name(accro))
    end

    def schedule_imports
      KindUtil.scan_accros.each do |accro|
        cron = import_cron(accro)
        schedule_import(accro) if cron.present?
      end
    end

    def remove_scheduled_imports
      KindUtil.scan_accros.each do |accro|
        remove_scheduled_import(accro)
      end
    end

    def handle_imports_schedules
      KindUtil.scan_accros.each do |accro|
        handle_import_schedule(accro)
      end
    end

    def handle_import_schedule(accro)
      if import_cron(accro).present?
        schedule_import(accro)
      else
        remove_scheduled_import(accro)
      end
    end

    def remove_scheduled_import(accro)
      Resque.remove_schedule(import_schedule_name(accro))
    end

    # If set_schedule is passed the name of an existing schedule, that schedule is updated.
    def schedule_import(accro)
      schedule_name = import_schedule_name(accro)
      cron = import_cron(accro)
      config = {
        class: 'ActiveJob::QueueAdapters::ResqueAdapter::JobWrapper',
        args: {
          job_class: "Importers::#{find_class}::#{accro.capitalize}::ScansImportJob",
          queue_name: 'default',
          priority: nil,
          arguments: [nil, id]
        },
        cron: cron.value,
        queue: 'default',
        persist: true,
        description: "Import #{accro} scans for #{name}"
      }
      Resque.set_schedule(schedule_name, config)
      ScheduledJob.find_or_create_by!(name: schedule_name) do |scheduled_job|
        scheduled_job.configuration = config
      end
    end

    def import_schedule_name(accro)
      return if name.blank?

      "import_#{accro}_scans_for_#{find_class.underscore}_config_#{name.underscore}"
    end

    def find_class
      self.class.to_s.chomp('Config')
    end
  end
end
# rubocop:enable Metrics/ModuleLength
