namespace :csis do
    task :version, [] => [:environment] do |task|
      puts CSIS::VERSION
    end
end

namespace :partition do
  task :versions, [] => [:environment] do |task|
    PaperTrail::MaintenanceService.manage_partitions
  end
end