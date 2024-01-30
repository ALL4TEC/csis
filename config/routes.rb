# frozen_string_literal: true

require 'resque/server'
require 'resque/scheduler'
require 'resque/scheduler/server'

USERABLE = %i[
  restorable activable confirmable unlockable recoverable otpable
].freeze

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'dashboard#index'

  # MFA
  concern :mfa_forcable do
    put 'force_mfa', on: :member
    put 'unforce_mfa', on: :member
  end

  concern :gpgable do
    get 'public_key', on: :member
  end

  concern :restorable do
    put 'restore', on: :member
  end

  concern :confirmable do
    put 'resend_confirmation', on: :member
    put 'force_confirm', on: :member
    put 'force_update_email', on: :member
  end

  concern :activable do
    put 'activate', on: :member
    put 'deactivate', on: :member
  end

  concern :unlockable do
    post 'send_unlock', on: :member
    put 'force_unlock', on: :member
  end

  concern :recoverable do
    post 'send_reset_password', on: :member
    put 'force_reset_password', on: :member
  end

  concern :otpable do
    put 'force_direct_otp', on: :member
    put 'force_unlock_otp', on: :member
    put 'force_deactivate_otp', on: :member
  end

  # ActionCable
  mount ActionCable.server, at: '/cable'

  # Disallow confirmation & unlock forms new/create
  devise_for :users,
    controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks',
      confirmations: 'users/confirmations',
      unlocks: 'users/unlocks',
      two_factor_authentication: 'users/two_factor_authentication',
      passwords: 'users/passwords'
    }
  devise_scope :users do
    get 'users/sign_in', to: 'devise/sessions#new', as: :login
    delete 'users/sign_out', to: 'devise/sessions#destroy', as: :logout
    get 'users/auth/saml/init/:idp', to: 'users/saml#init', as: :saml_init
    post 'users/auth/saml/consume/:idp', to: 'users/saml#consume', as: :saml_consume
    get 'users/auth/saml/meta/:idp', to: 'users/saml#metadata', as: :saml_metadata
    get 'users/auth/saml/logout', to: 'users/saml#logout', as: :saml_logout
  end

  # User profile
  get '/profile', to: 'users/profile#show'
  get '/edit/profile/password', to: 'users/profile#edit_password'
  put '/edit/profile/password', to: 'users/profile#update_password'
  get '/edit/profile/public_key', to: 'users/profile#edit_public_key'
  put '/edit/profile/public_key', to: 'users/profile#update_public_key'
  get '/edit/profile/display', to: 'users/profile#edit_display'
  put '/edit/profile/display', to: 'users/profile#update_display'
  get '/edit/profile/notifications', to: 'users/profile#edit_notifications'
  put '/edit/profile/notifications', to: 'users/profile#update_notifications'
  get '/edit/profile/otp', to: 'users/profile#edit_otp'
  post '/otp/activate', to: 'users/profile#activate_otp', as: :activate_otp
  post '/otp/deactivate', to: 'users/profile#deactivate_otp', as: :deactivate_otp
  post '/otp/authenticator/setup',
    to: 'users/profile#setup_otp_authenticator', as: :setup_otp_authenticator
  post '/otp/authenticator/setup/new',
    to: 'users/profile#resetup_otp_authenticator', as: :resetup_otp_authenticator
  post '/otp/authenticator/clear',
    to: 'users/profile#clear_otp_authenticator', as: :clear_otp_authenticator
  get '/otp/authenticator/:token',
    to: 'users/profile#configure_totp', as: :configure_otp_authenticator
  post '/otp/authenticator/test',
    to: 'users/profile#test_totp_configuration', as: :test_totp_configuration
  put '/switch_current_group/:id',
    to: 'users/profile#switch_current_group', as: :switch_view

  authenticate :user, ->(u) { u&.staff? && u&.super_admin? } do
    mount Resque::Server, at: '/debug/jobs'
  end

  if Rails.application.config.rapid7_ias_enabled
    resources :insight_app_sec_configs, shallow: true do
      post '/import/scans', to: 'insight_app_sec_configs#import_scans'
      post '/update/scans', to: 'insight_app_sec_configs#update_scans'
      delete '/delete/scan', to: 'insight_app_sec_configs#delete_scan'
    end
  end

  if Rails.application.config.qualys_enabled
    resources :qualys_configs, shallow: true, concerns: %i[activable] do
      resources :qualys_vm_clients
      resources :qualys_wa_clients
      post '/import/scans/vm', to: 'qualys_configs#vm_scans_import'
      post '/import/scans/wa', to: 'qualys_configs#wa_scans_import'
      post '/import/vulnerabilities', to: 'qualys_configs#vulnerabilities_import'
      post '/update/scans/vm', to: 'qualys_configs#vm_scans_update'
      post '/update/scans/wa', to: 'qualys_configs#wa_scans_update'
      delete '/delete/scan/vm', to: 'qualys_configs#vm_scan_delete'
      delete '/delete/scan/wa', to: 'qualys_configs#wa_scan_delete'
    end
    get '/qualys_vm_clients', to: 'qualys_vm_clients#list', as: :qualys_vm_clients
    get '/qualys_wa_clients', to: 'qualys_wa_clients#list', as: :qualys_wa_clients
  end

  if Rails.application.config.sellsy_enabled
    resources :sellsy_configs do
      post '/import', to: 'sellsy_configs#import'
    end
  end

  if Rails.application.config.cyberwatch_enabled
    resources :cyberwatch_configs, concerns: %i[activable] do
      post '/import/scans', to: 'cyberwatch_configs#scans_import'
      post '/import/vulnerabilities', to: 'cyberwatch_configs#vulnerabilities_import'
      post '/import/assets', to: 'cyberwatch_configs#assets_import'
      put '/update/scans', to: 'cyberwatch_configs#scans_update'
      delete '/delete/scan', to: 'cyberwatch_configs#scan_delete'
      post 'ping', to: :member
    end
  end

  # Communication tools
  get 'chat_configs', to: 'chat_configs#index'
  # Chat providers
  if Rails.application.config.slack_enabled
    resources :slack_applications, only: %i[create edit new update destroy]
    resources :slack_configs, only: %i[index edit update destroy]
    get '/slack/oauth', to: 'slack_configs#oauth' # = slack_configs#new
  end

  if Rails.application.config.google_chat_enabled
    resources :google_chat_configs, only: %i[index create edit new update destroy]
  end

  if Rails.application.config.microsoft_teams_enabled
    resources :microsoft_teams_configs, only: %i[index create edit new update destroy]
  end

  if Rails.application.config.zoho_cliq_enabled
    resources :zoho_cliq_configs, only: %i[index create edit new update destroy]
  end

  if Rails.application.config.jira_enabled
    resources :jira_configs
    get '/jira/oauth', to: 'jira_configs#oauth'
  end

  if Rails.application.config.servicenow_enabled
    resources :servicenow_configs
    get '/servicenow/oauth', to: 'servicenow_configs#oauth'
  end

  resources :matrix42_configs if Rails.application.config.matrix42_enabled

  resources :groups, only: %i[index], concerns: %i[mfa_forcable] do
    post 'users/:user_id', on: :member, to: 'groups#add_user', as: :add_user_to
    delete 'users/:user_id', on: :member, to: 'groups#remove_user', as: :remove_user_from
    get 'users', on: :collection, to: 'groups#users'
    get 'staff', on: :collection, to: 'groups#staff'
    get 'contact', on: :collection, to: 'groups#contact'
  end
  resources :roles, only: [], concerns: [:mfa_forcable]
  resources :teams, concerns: %i[restorable mfa_forcable]
  resources :staffs, concerns: USERABLE
  resources :clients, concerns: %i[restorable mfa_forcable]
  resources :contacts, concerns: USERABLE
  resources :idp_configs, concerns: %i[restorable activable]
  resources :users, only: [], concerns: %i[gpgable mfa_forcable]

  # All reports
  get '/reports', to: 'reports#all'

  # Settings
  get '/settings', to: 'settings#index'
  post '/settings/certificates/bg', to: 'settings#upload_certificates_bg'
  post '/settings/wsc/thumbs', to: 'settings#upload_wsc_thumbs'
  post '/settings/badges', to: 'settings#upload_badges'
  post '/settings/reports/logo', to: 'settings#upload_reports_logo'
  post '/settings/mails/logo', to: 'settings#upload_mails_logo'
  post '/settings/mails/webicons', to: 'settings#upload_mails_webicons'
  post '/settings/reset', to: 'settings#reset'
  post '/settings/customize', to: 'settings#customize'
  put '/settings/stats', to: 'settings#update_certs_and_stats'

  # Jobs
  get '/jobs', to: 'jobs#index'
  get '/jobs/:id', to: 'jobs#detail'

  # Imports
  post 'settings/import/sellsy', to: 'settings#import_sellsy'

  resources :audit_logs, only: %i[index]

  post 'dashboard/locale', to: 'application#change_locale'
  get 'dashboard', to: 'dashboard#index', as: :dashboard
  get 'dashboard/vulnerabilities', to: 'dashboard#vulnerabilities_occurencies'
  get 'dashboard/last_reports', to: 'dashboard#last_reports'
  get 'dashboard/last_vm_scans', to: 'dashboard#last_vm_scans'
  get 'dashboard/last_wa_scans', to: 'dashboard#last_wa_scans'
  get 'dashboard/last_active_actions', to: 'dashboard#last_active_actions'
  post 'dashboard/default_card', to: 'dashboard#toggle_default_card'
  resources :vulnerabilities, only: %i[index show] do
    get 'burp', on: :collection
    get 'qualys', on: :collection
    get 'cve', on: :collection
    get 'zaproxy', on: :collection
    get 'nessus', on: :collection
    get 'cyberwatch', on: :collection
  end
  scope '/imports' do
    get '/vulnerabilities', to: 'vulnerabilities_imports#index', as: 'vulnerabilities_imports'
    get '/vulnerabilities/new', to: 'vulnerabilities_imports#new', as: 'new_vulnerabilities_import'
    post '/vulnerabilities', to: 'vulnerabilities_imports#create', as: 'vulnerabilities_import'
    delete '/vulnerabilities/:id', to: 'vulnerabilities_imports#destroy'
  end

  get 'statistics', to: 'statistics#show'
  post 'statistics', to: 'statistics#show'
  get 'statistics/export', to: 'statistics#export'
  post 'statistics/export', to: 'statistics#generate'

  # Pour que '/actions' ne render pas #index mais que seul '/aggregate/:id/actions' le fasse
  get 'actions', to: 'actions#active'

  resources :actions do
    put 'restore', on: :member
    get 'trashed', on: :collection
    get 'clotured', on: :collection
    get 'archived', on: :collection
    post 'updates', on: :collection

    if Rails.application.config.servicenow_enabled || Rails.application.config.jira_enabled
      resources :issues, only: %i[create destroy]
    end
  end

  post 'aggregates/duplicate', to: 'aggregates#bulk_duplicate'

  resources :projects do
    get 'trashed', on: :collection
    put 'restore', on: :member
    put 'regenerate_scoring', on: :member
    put 'regenerate_all_scoring', on: :collection

    resources :reports, except: %i[show new create edit update], shallow: true do
      put 'regenerate_scoring', on: :member
      put 'restore', on: :member
      post 'notify', on: :member
      post 'aggregates/reorder', on: :member, to: 'aggregates#reorder'
      delete 'aggregates', on: :member, to: 'aggregates#bulk_delete'
      get 'actions', on: :member, to: 'action_plan_reports#action_plans'
      resources :aggregates do
        post 'down', on: :member
        post 'up', on: :member
        post 'toggle_visibility', on: :member
        get 'edit_attachment', on: :member
        put 'update_attachment', on: :member
        post 'apply_order', on: :collection, to: 'aggregates#apply_order'
        put 'order', on: :collection, to: 'aggregates#save_order'
        put 'merge', on: :member
        resources :actions do
          resources :dependencies, only: %i[index new create], shallow: true do
            put 'restore', on: :member
            post 'updates', on: :collection
          end
          post 'comment', on: :member
          post 'updates', on: :collection
        end
      end
      resources :exports, only: %i[index create destroy], controller: :report_exports
      resources :notes, except: %i[new create update]
      get '/notes/new', to: 'notes#new', as: 'new_note'
      resources :scan_imports, only: %i[index new create destroy], controller: :report_scan_imports
      resources :scan_launches, only: %i[index new destroy], controller: :report_scan_launches do
        post 'zaproxy', on: :collection if 'zaproxy'.in?(Rails.application.config.scb_scanners)
        post :import, on: :member
      end
      post 'auto_aggregate', on: :member
    end

    resources :scan_reports, only: %i[show new create edit update], shallow: true
    resources :scheduled_scans, only: %i[index new], controller: :scheduled_scans do
      post 'zaproxy', on: :collection if 'zaproxy'.in?(Rails.application.config.scb_scanners)
    end

    if Rails.application.config.pentest_enabled
      resources :pentest_reports, only: %i[show new create edit update], shallow: true do
        get 'new_vulnerability_scan', on: :member
        get 'new_appendix', on: :member
      end
    end

    if Rails.application.config.action_plan_enabled
      resources :action_plan_reports, only: %i[show new create edit update], shallow: true do
        get 'new_appendix', on: :member
      end
    end

    resources :statistics, only: %i[index] do
      post 'update_certificate', on: :collection
    end
  end

  resources :scheduled_scans, only: [:destroy], concerns: [:activable]

  resources :vm_scans, only: %i[show] do
    get 'occurrences/:occurrence_id', on: :member, to: 'vm_scans#show_occurrence', as: :occurrence
  end
  resources :wa_scans, only: %i[show] do
    get 'occurrences/:occurrence_id', on: :member, to: 'wa_scans#show_occurrence', as: :occurrence
  end

  resources :notes, only: %i[restore] do
    put 'restore', on: :member
  end
  put '/notes', to: 'notes#autosave', as: 'autosave_note'

  # Path needed to avoid conflicts with application assets (Method Not Allowed)
  resources :assets, path: 'my_assets' do
    get 'trashed', on: :collection
    put 'restore', on: :member
    resources :targets, shallow: true do
      put 'restore', on: :member
    end
  end

  # All targets
  get '/targets', to: 'targets#all'

  post '/webhook/sellsy/3455ecd1-1d58-4e57-842f-c3d691694d24', to: 'webhook#sellsy'
  post "/webhook/securecodebox/#{ENV.fetch('SECURE_CODE_BOX_WH_UUID', nil)}",
    to: 'webhook#securecodebox'
  post '/whois', to: 'whois#whois'
  get '/changelog', to: 'changelog#history'

  visualize if ENV['RAILS_ENV'] == 'development' # at /routes
end
