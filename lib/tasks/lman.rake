namespace :lman do
  task :upload_report_now, [] => [:environment] do |task|
    LmanReportUploaderJob.perform_now()
  end
  
  task :upload_report_later, [] => [:environment] do |task|
    LmanReportUploaderJob.perform_later()
  end
end
