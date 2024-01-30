namespace :qualys do
  namespace :vulnerabilities do
    # import_all task launch importation of all Qualys vulnerabilities
    task :import_all, [] => [:environment] do |task|
      consultants_config = QualysConfig.kept_consultants.first
      Importers::Qualys::VulnerabilitiesImportJob.perform_later(nil, consultants_config.id, last: false) if consultants_config.present?
    end

    task :import_all_now, [] => [:environment] do |task|
      consultants_config = QualysConfig.kept_consultants.first
      puts "Import vulnerabilities - Start for #{consultants_config}"
      Importers::Qualys::VulnerabilitiesImportJob.perform_now(nil, consultants_config.id, last: false) if consultants_config.present?
      puts "Import vulnerabilities - End"
    end

    # import_last task launch importation of all Qualys vulnerabilities modified after the most recent vulnerability in base
    task :import_last, [] => [:environment] do |task|
      consultants_config = QualysConfig.kept_consultants.first
      Importers::Qualys::VulnerabilitiesImportJob.perform_later(nil, consultants_config.id, last: true) if consultants_config.present?
    end

    task :import_last_now, [] => [:environment] do |task|
      consultants_config = QualysConfig.kept_consultants.first
      puts "Import last vulnerabilities - Start for #{consultants_config}"
      Importers::Qualys::VulnerabilitiesImportJob.perform_now(nil, consultants_config.id, last: true) if consultants_config.present?
      puts "Import last vulnerabilities - End"
    end
  end

  namespace :scans do
    task :import, [] => [:environment] do |task|
      QualysConfig.active.each do |account|
        since_date = 1.weeks.ago.to_date.to_s
        Importers::Qualys::Wa::ScansImportJob.perform_later(nil, account.id, {launched_date: since_date})
        Importers::Qualys::Vm::ScansImportJob.perform_later(nil, account.id, {launched_after_datetime: since_date})
      end
    end

    task :import_now, [] => [:environment] do |task|
      puts "Import scans - Start"
      QualysConfig.active.each do |account|
        since_date = 1.weeks.ago.to_date.to_s
        Importers::Qualys::Wa::ScansImportJob.perform_now(nil, account.id, {launched_date: since_date})
        Importers::Qualys::Vm::ScansImportJob.perform_now(nil, account.id, {launched_after_datetime: since_date})
      end
      puts "Import scans - End"
    end
  end
end
