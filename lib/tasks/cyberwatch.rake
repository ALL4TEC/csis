# /!\ Pour que l'authent fonctionne, il faut être à la même heure que le server.
# sudo ntpdate ntp.ubuntu.com

namespace :cyberwatch do
  namespace :test do
    task :auth, [] => [:environment] do |task|
      account = CyberwatchConfig.first
      token = Cyberwatch::Request.auth(account)
      puts "Authorization Token: \"#{token['Authorization']}\""
    end

    task :ping, [] => [:environment] do |task|
      account = CyberwatchConfig.first
      resp = Cyberwatch::Request.ping(account)
      puts "Ping response : #{resp.code} #{resp.message}"
    end

    task :assets, [] => [:environment] do |task|
      account = CyberwatchConfig.first
      resp = Importers::Cyberwatch::AssetsImportJob.perform_now(nil, account.id, {})
      puts "Successfully imported #{resp} assets !"
    end

    task :vulnerabilities, [] => [:environment] do |task|
      account = CyberwatchConfig.first
      resp = Importers::Cyberwatch::VulnerabilitiesImportJob.perform_now(nil, account.id, {})
      puts "Successfully imported #{resp} vulnerabilities !"
    end

    task :scans, [] => [:environment] do |task|
      account = CyberwatchConfig.first
      resp = Importers::Cyberwatch::ScansImportJob.perform_now(nil, account.id, {})
      puts "Successfully imported #{resp} scans !"
    end
  end
end
