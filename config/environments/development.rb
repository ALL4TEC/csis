# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # CHANGE the following line; it's :memory_store by default
  config.cache_store = :redis_cache_store,
                       { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }

  # ADD the following line; it probably doesn't exist
  config.session_store :cache_store, key: '_sessions_development', compress: true, pool_size: 5,
    expire_after: 1.year

  # Set ROOT_URL ENV variable
  ENV['ROOT_URL'] ||= 'https://localhost:3001'
  # Set LMAN_URL ENV variable
  ENV['LMAN_ROOT'] ||= 'http://localhost:3001'
  # Set DISPLAY_UNKNOWN_VERSIONS ENV variable
  ENV['DISPLAY_UNKNOWN_VERSIONS'] ||= 'true'
  # Set SAML_SP_CERTIFICATE
  ENV['SAML_SP_CERTIFICATE'] ||= File.read('saml/saml.crt')
  # Set SAML_SP_PRIVATE_KEY
  ENV['SAML_SP_PRIVATE_KEY'] ||= File.read('saml/saml.pem')

  # Set useful/overridable variables for resque-kubernetes
  ENV['RESQUE_KUBERNETES'] ||= 'false'

  # Settings specified here will take precedence over those in config/application.rb.

  config.webpacker.check_yarn_integrity = false

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  config.i18n.raise_on_missing_translations = true
  config.i18n.exception_handler = proc { |exception| raise exception.to_exception }

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.file_watcher = ActiveSupport::FileUpdateChecker

  # Default mailer settings for development environments
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_options = { from: ENV.fetch('ACTIONS_EMAIL', '') }
  config.action_mailer.delivery_job = 'ActionMailer::MailDeliveryJob'

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('SMTP_ADDRESS', ''),
    port: ENV.fetch('SMTP_PORT', 587),
    user_name: ENV.fetch('MAIL_USER_NAME', nil),
    password: ENV.fetch('MAIL_PWD', nil),
    domain: ENV.fetch('SMTP_DOMAIN', ''),
    authentication: (ENV.fetch('SMTP_AUTHENTICATION') { :login }).to_sym,
    enable_starttls_auto: ENV.fetch('SMTP_ENABLE_STARTTLS_AUTO', 'true') == 'true'
  }

  config.web_console.whitelisted_ips = '172.0.0.0/8'
  config.after_initialize do
    Bullet.enable = false
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
  end

  # Connecteurs
  config.qualys_enabled = ENV.fetch('QUALYS_ENABLED', 'true') == 'true'
  config.sellsy_enabled = ENV.fetch('SELLSY_ENABLED', 'true') == 'true'
  config.rapid7_ias_enabled = ENV.fetch('RAPID7_IAS_ENABLED', 'true') == 'true'
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

  # Modules
  config.pentest_enabled = ENV.fetch('PENTEST_ENABLED', 'true') == 'true'
  config.action_plan_enabled = ENV.fetch('ACTION_PLAN_ENABLED', 'true') == 'true'

  # Display unknown versions in user activity: Useful for preprod
  config.display_unknown_versions = ENV.fetch('DISPLAY_UNKNOWN_VERSIONS', 'true') == 'true'

  # Securecodebox scanners
  config.scb_scanners = ENV.fetch('SCB_SCANNERS', 'zaproxy').split(',')
end
