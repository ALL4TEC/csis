namespace :schedule do
  task :stored_jobs, [] => [:environment] do |task|
    Schedulers::StoredJobs.reschedule
  end

  task :maintenance, [] => [:environment] do |task|
    PaperTrail::Version.schedule_maintenance
  end
end
