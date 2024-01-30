# frozen_string_literal: true

Rails.application.configure do
  # Set ROOT_URL ENV variable
  ENV['ROOT_URL'] ||= ''
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = false
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :terser
  config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved
  # to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "console_#{Rails.env}"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate
  # delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = [I18n.default_locale]

  # Send deprecation notices to registered listeners.
  # config.active_support.deprecation = :notify
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Settings for user_mailer. (Ajouter le MDP dans une variable d'environnement)
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_options = { from: ENV.fetch('ACTIONS_EMAIL', '') }
  config.action_mailer.delivery_job = 'ActionMailer::MailDeliveryJob'

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: ENV.fetch('ROOT_URL', nil) }
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('SMTP_ADDRESS', ''),
    port: ENV.fetch('SMTP_PORT', 587),
    user_name: ENV.fetch('MAIL_USER_NAME', nil),
    password: ENV.fetch('MAIL_PWD', nil),
    domain: ENV.fetch('SMTP_DOMAIN', ''),
    authentication: (ENV.fetch('SMTP_AUTHENTICATION') { :login }).to_sym,
    enable_starttls_auto: ENV.fetch('SMTP_ENABLE_STARTTLS_AUTO', 'true') == 'true'
  }

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Connecteurs
  config.qualys_enabled = ENV.fetch('QUALYS_ENABLED', 'true') == 'true'
  config.sellsy_enabled = ENV.fetch('SELLSY_ENABLED', 'false') == 'true'
  config.rapid7_ias_enabled = ENV.fetch('RAPID7_IAS_ENABLED', 'false') == 'true'
  config.cyberwatch_enabled = ENV.fetch('CYBERWATCH_ENABLED', 'true') == 'true'

  # Communication tools
  config.slack_enabled = ENV.fetch('SLACK_ENABLED', 'true') == 'true'
  config.google_chat_enabled = ENV.fetch('GOOGLE_CHAT_ENABLED', 'true') == 'true'
  config.microsoft_teams_enabled = ENV.fetch('MICROSOFT_TEAMS_ENABLED', 'true') == 'true'
  config.zoho_cliq_enabled = ENV.fetch('ZOHO_CLIQ_ENABLED', 'true') == 'true'
  config.jira_enabled = ENV.fetch('JIRA_ENABLED', 'true') == 'true'
  config.servicenow_enabled = ENV.fetch('SERVICENOW_ENABLED', 'true') == 'true'
  config.matrix42_enabled = ENV.fetch('MATRIX42_ENABLED', 'true') == 'true'
  # If PMT_CHECKER_INTERNET is true, pmt:check_configs Rake task will call
  # services APIs to check the config validity instead of just checking local expiration date
  config.pmt_checker_internet = ENV.fetch('PMT_CHECKER_INTERNET', 'true') == 'true'

  # Reports Modules
  config.pentest_enabled = ENV.fetch('PENTEST_ENABLED', 'false') == 'true'
  config.action_plan_enabled = ENV.fetch('ACTION_PLAN_ENABLED', 'true') == 'true'

  # unknown versions
  config.display_unknown_versions = ENV.fetch('DISPLAY_UNKNOWN_VERSIONS', 'false') == 'true'

  # Host Header Injection #345
  config.hosts = ENV.fetch('HOSTS', '').split(',')
  # Securecodebox scanners
  config.scb_scanners = ENV.fetch('SCB_SCANNERS', '').split(',')
end
