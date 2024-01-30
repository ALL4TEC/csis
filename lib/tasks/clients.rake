namespace :sellsy do
  task :import, [] => [:environment] do |task|
    SellsyConfig.all.each do |account|
      Importers::SellsyImportJob.perform_later(nil, account)
    end
  end

  task :import_now, [] => [:environment] do |task|
    SellsyConfig.all.each do |account|
      puts "Import Sellsy - Start"
      Importers::SellsyImportJob.perform_now(nil, account)
      puts "Import Sellsy - End"
    end
  end
end
