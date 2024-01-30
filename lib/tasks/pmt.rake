namespace :pmt do
  # check if PMT configurations are still valid (unreachable server, expired/invalidated token...)
  task :check_configs, [] => [:environment] do |task|
    Watchers::JiraConfigExpiryJob.perform_now()
  end
end
