# Useful ?

namespace :pdf do
  task :gen_scan_report_now, [:export_id, :archi] => [:environment] do |task|
    Generators::ScanReportGeneratorJob.perform_now(args[:export_id], args[:archi])
  end
  
  task :gen_scan_report_later, [:export_id, :archi] => [:environment] do |task|
    Generators::ScanReportGeneratorJob.perform_later(args[:export_id], args[:archi])
  end

  task :gen_pentest_report_now, [:export_id] => [:environment] do |task|
    Generators::PentestReportGeneratorJob.perform_now(args[:export_id])
  end
  
  task :gen_pentest_report_later, [:export_id] => [:environment] do |task|
    Generators::PentestReportGeneratorJob.perform_later(args[:export_id])
  end

  task :gen_certificate_now, [:project, :lang] => [:environment] do |task|
    Generators::CertificateGeneratorJob.perform_now(args[:project], args[:lang])
  end

  task :gen_certificate_later, [:project, :lang] => [:environment] do |task|
    Generators::CertificateGeneratorJob.perform_later(args[:project], args[:lang])
  end
end
