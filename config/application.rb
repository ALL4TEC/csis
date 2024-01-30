# frozen_string_literal: true

require_relative 'boot'
ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'
require 'rails/all'

require 'appmap/railtie' if defined?(AppMap)

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Csis
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.time_zone = 'Paris'

    lib_content = %W[
      #{config.root}/lib/common/
      #{config.root}/lib/sellsy/
      #{config.root}/lib/inuit/
      #{config.root}/lib/qualys/
      #{config.root}/lib/qualys_wa/
      #{config.root}/lib/breadcrumbs/
      #{config.root}/lib/burp/
      #{config.root}/lib/nist/
      #{config.root}/lib/zaproxy/
      #{config.root}/lib/nessus/
      #{config.root}/lib/kubernetes/
      #{config.root}/lib/secure_code_box/
      #{config.root}/lib/cyberwatch/
      #{config.root}/lib/jira/
      #{config.root}/lib/servicenow/
      #{config.root}/lib/matrix42/
      #{config.root}/lib/with_secure/
    ]

    config.autoload_paths += lib_content

    config.eager_load_paths += lib_content

    # Locales available for the application
    I18n.available_locales = %i[en fr]

    # Set default locale to french
    I18n.default_locale = :fr

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.active_job.queue_adapter = :resque
    config.active_record.schema_format = :sql
    # https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time]

    config.assets.enabled = false

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.scaffold_stylesheet false
      g.javascripts false
      g.stylesheets false
      g.assets false
    end

    # https://rubysec.com/advisories/CVE-2022-32224/
    config.active_record.yaml_column_permitted_classes = [Time]
  end
end
