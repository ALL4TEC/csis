Resque::Kubernetes.configuration do |config|
  config.enabled     = ENV.fetch('RESQUE_KUBERNETES', 'true') == 'true'
  config.max_workers = ENV.fetch('MAX_WORKERS', 3)
end
