# frozen_string_literal: true

Rails.application.configure do
  # Set ROOT_URL ENV variable
  ENV['ROOT_URL'] ||= 'http://localhost:3000'
  # Set LMAN_URL ENV variable
  ENV['LMAN_ROOT'] ||= 'http://localhost:3001'
  # Set Postgresql password
  ENV['POSTGRES_PASSWORD'] ||= '' # TODO: Customize
  # Set SAML_SP_CERTIFICATE
  ENV['SAML_SP_CERTIFICATE'] ||= File.read('saml/saml.crt')
  # Set SAML_SP_PRIVATE_KEY
  ENV['SAML_SP_PRIVATE_KEY'] ||= File.read('saml/saml.pem')

  # Set useful/overridable variables for resque-kubernetes
  ENV['RESQUE_KUBERNETES'] ||= 'false'

  # SECURE CODE BOX WEBHOOK
  ENV['SECURE_CODE_BOX_WH_UUID'] ||= SecureRandom.uuid

  # Settings specified here will take precedence over those in config/application.rb.
  config.webpacker.check_yarn_integrity = false
  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Eager loading loads your whole application. When running a single test locally,
  # this probably isn't necessary. It's a good idea to do in a continuous integration
  # system, or in some way before deploying your code.
  config.eager_load = ENV['CI'].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Default mailer settings for test environments
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_options = { from: ENV.fetch('ACTIONS_EMAIL', '') }
  config.action_mailer.delivery_job = 'ActionMailer::MailDeliveryJob'

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: 'localhost:3000/' }
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('SMTP_ADDRESS', ''),
    port: ENV.fetch('SMTP_PORT', 587),
    user_name: ENV.fetch('MAIL_USER_NAME', nil),
    password: ENV.fetch('MAIL_PWD', nil),
    domain: ENV.fetch('SMTP_DOMAIN', ''),
    authentication: (ENV.fetch('SMTP_AUTHENTICATION') { :login }).to_sym,
    enable_starttls_auto: ENV.fetch('SMTP_ENABLE_STARTTLS_AUTO', 'true') == 'true'
  }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations
  config.i18n.raise_on_missing_translations = true
  config.i18n.exception_handler = proc { |exception| raise exception.to_exception }
  config.after_initialize do
    Bullet.enable = true
    # Bullet.raise = true
    Bullet.bullet_logger = true
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

  # Versions unknown
  config.display_unknown_versions = ENV.fetch('DISPLAY_UNKNOWN_VERSIONS', 'true') == 'true'

  # Securecodebox scanners
  config.scb_scanners = ENV.fetch('SCB_SCANNERS', 'zaproxy').split(',')
  # Securecodebox webhook IP validator
  ENV['SCB_WEBHOOK_WHITELIST'] = '193.252.117.145, 8.8.8.8'
end
