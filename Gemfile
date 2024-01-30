source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 2.5.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '7.0.8'
gem 'rails-i18n', '7.0.8'
# Use PostgreSQL as the database for Active Record
gem 'pg', '~> 1.0'
# Use Puma as the app server
gem 'puma'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Js compilation
gem 'terser'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5'
# Move from turbolinks to turbo
gem 'turbo-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', platforms: :ruby

# Excel exports
gem 'caxlsx'
gem 'caxlsx_rails'

gem 'bulk_insert'
gem 'discard', '~> 1.0'
# Kaminari pagination library (& translations)
gem 'kaminari'
gem 'kaminari-i18n'

# Rails form DSL with bundled bootstrap theme
gem 'simple_form'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Permits attribute encryption in DB
# Temporary fix while waiting for a migration to Rails 7 encryption default
# gem 'attr_encrypted', git: 'https://github.com/r7kamura/attr_encrypted.git', branch: 'feature/encrypted-attributes'
gem 'attr_encrypted', git: 'https://github.com/PagerTree/attr_encrypted.git', branch: 'rails-7-0-support'

# Puts autocomplete="off" on every input and form
gem "autocomplete-off"

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Group by helpers
gem 'groupdate'
# Charts
gem "chartkick"

# Devise authentication library (& translations)
gem 'devise'
gem 'devise-i18n'

# 2FA
gem 'two_factor_authentication'
# QrCode
gem 'rqrcode'

# Weak passwords
gem 'devise_zxcvbn'

# Tasks arguments
gem 'optparse'

# Secure GPG Mailer
gem 'gpgme'
gem 'mail-gpg'

# Omniauth authentication framework
gem 'omniauth', '>= 2.0'

# Omniauth Google authentication adapter
gem 'omniauth-google-oauth2'
# Omniauth Azure AD authentication adapter
gem 'omniauth-azure-activedirectory-v2'

# Ruby SAML Gem from OneLogin
gem 'ruby-saml', '~> 1.11'

# HMAC auth for CyberWatch
gem 'api-auth'

# Object-relational mapping for REST web services
gem 'activeresource'

# Decorator stack for Ruby on Rails
gem 'draper'

# Audited log library
gem 'paper_trail'
# gem 'paper_trail-association_tracking' # Not used and causes NoMethodError scope for module
# Used to load YAML. The YAML module is an alias of Psych, the YAML engine for Ruby.
gem 'psych', '~> 3'

# Authorization library
gem 'pundit'

# Phone number parsing library
gem 'phonelib'

# PDF Generator
gem 'prawn'
gem 'prawn-table'
gem 'prawn-graph', path: 'vendor/prawn-graph'

# Resque background jobs
gem 'resque-kubernetes'
gem 'redis', '~> 4.0' # Force Redis version to be 3.x
gem 'resque', '~> 2' # Waiting for Rails::Railtie fix
# gem 'resque', git: 'https://github.com/ineluki00/resque.git', branch: 'fix_railtie_nameerror'
gem 'resque-scheduler'

# Ransack object based searching
gem 'ransack'

#Rot13 cipher for file name
gem 'rot13'

# Whois
gem 'whois'
gem 'whois-parser'
gem 'domainatrix'

# Faraday
gem 'faraday'

# Downloading file
gem 'down'

# Better polling logic on Windows
gem 'wdm', '>= 0.1.0' if Gem.win_platform?

# Documentation engine
gem 'sdoc', '~> 1.0'

# Roles
gem "rolify"

# Bread crumbs
gem 'breadcrumbs_on_rails'

# ActiveStorage variants
gem 'image_processing'
gem 'ruby-vips'

# CSRF protection
gem "omniauth-rails_csrf_protection"

# Markdown
gem 'redcarpet'

# Errors
gem 'exception_handler'

# Quicktype
gem 'dry-types'
gem 'dry-struct'

# PG partitioning
gem 'pg_party'

# AR Union
gem 'active_record_extended'

# Slack
gem 'slack-ruby-client'

# View component
gem 'view_component', '~> 2', require: 'view_component/engine'

group :development, :test do
  # Ruby static code analyzer
  gem 'rubocop', '>= 0.72.0', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false

  # Brakeman: security
  gem 'brakeman', require: false
  # Flay: duplicates
  gem 'flay', require: false
  # Reek
  gem 'reek', require: false
  # Audit bundle
  gem 'bundler-audit', require: false
  # Lint erbs
  # gem 'erb_lint', require: false
  # Fasterer
  gem 'fasterer', require: false
  # Bullet
  gem 'bullet', require: true

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # Create Fake names, apps, ...
  gem 'faker'

  # Dump database into seed
  gem 'seed_dump'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # gem 'listen'
  # Console Inspection
  gem 'pry-rails'
  # Debugger
  # gem 'ruby-debug-ide'
  # gem 'debase', '>= 0.2.2.beta.10'
  # Rails panel for logs access from chrome
  # gem 'meta_request'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Generate db schema
  gem 'rails-erd'
  # Solargraph
  gem 'solargraph'
  # routes visualisation
  gem 'router-visualizer'
end

group :test do
  # Stub constants for the duration of a block in MiniTest
  gem 'minitest-stub-const'
  gem 'minitest-stub_any_instance'
  # Reporter
  gem 'minitest-reporters'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.18'
  gem 'selenium-webdriver'
  gem 'webdrivers', '~> 3.0'
  # Code coverage
  gem 'simplecov', require: false
  # Mocks and stubs
  gem 'mocha'
  # Time related tests
  gem 'timecop'
  # Stimulus reflex
  gem 'stimulus_reflex_testing'
  gem "rspec", "~> 3.10"
  gem 'rspec-rails', '~> 5.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# SSR gems: Stimulus Reflex
gem "cable_ready", "~> 4.5.0"
gem "stimulus_reflex", "~> 3.4.1"

# Jira integration
gem 'jira-ruby', "~> 2.2.0"

gem 'matrix'
