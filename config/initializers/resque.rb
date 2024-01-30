rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'
config_file = rails_root + '/config/resque.yml'

if ENV['RAILS_LOG_TO_STDOUT'].present?
  Resque.logger = ActiveSupport::Logger.new(STDOUT)
else
  Resque.logger.level = Logger::DEBUG
  Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))
end

resque_config = YAML::load(ERB.new(IO.read(config_file)).result)
Resque.redis = resque_config[rails_env]

# Permet d'avoir un bouton delete sur resque-web pour les schedules
Resque::Scheduler.dynamic = true
