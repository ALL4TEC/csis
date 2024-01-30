# frozen_string_literal: true

class UserMailer < ApplicationMailer
  ACTIONS_FROM = ENV.fetch('ACTIONS_EMAIL', '')
  NEW_ACTIONS = 'mailer.subjects.new_actions'
  ### NOTIFICATIONS ###
  NOTIFICATIONS = 'mailer.subjects.notifications'
  EXCEEDING_SEVERITY_THRESHOLD = "#{NOTIFICATIONS}.exceeding_severity_threshold".freeze
  ACTION_STATE_UPDATE = "#{NOTIFICATIONS}.action_state_update".freeze
  COMMENT_CREATION = "#{NOTIFICATIONS}.comment_creation".freeze
  EXPORT_GENERATION = "#{NOTIFICATIONS}.export_generation".freeze
  SCAN_LAUNCH_DONE = "#{NOTIFICATIONS}.scan_launch_done".freeze
  SCAN_CREATED = "#{NOTIFICATIONS}.scan_created".freeze
  SCAN_DESTROYED = "#{NOTIFICATIONS}.scan_destroyed".freeze

  before_action do
    @tmp = I18n.locale
  end

  after_action do
    I18n.locale = @tmp
  end

  # Envoi des actions à un contact s'il possède une gpg public_key
  def action_crypted(user, choices)
    call(user, NEW_ACTIONS, :crypted, { from: ACTIONS_FROM }) do
      @actions = Action.find(choices)
      @url = new_user_session_url
    end
  end

  # Envoi des actions à un contact s'il ne possède pas de clé publique gpg
  def action(user)
    call(user, NEW_ACTIONS, :plain, { from: ACTIONS_FROM }) do
      @url = new_user_session_url
    end
  end

  # L'utilisateur doit être informé de l'apparition d'une nouvelle vulnérabilité
  # @param **user:** User to mail to
  # @param **notif:** Notification
  # @param **data:** Additional data to display
  def exceeding_severity_threshold_notification(user, _notif, data)
    call(user, EXCEEDING_SEVERITY_THRESHOLD, :plain) do
      @url = scan_report_url(data[:report])
    end
  end

  # L'utilisateur doit être informé de l'apparition d'une nouvelle vulnérabilité chiffré
  # @param **user:** User to mail to
  # @param **notif:** Notification
  # @param **data:** Additional data to display
  def exceeding_severity_threshold_notification_crypted(user, _notif, data)
    call(user, EXCEEDING_SEVERITY_THRESHOLD, :crypted) do
      @url = scan_report_url(data[:report])
      @occurrences = data[:occurrences]
    end
  end

  ### Action state update ###

  def handle_action_state_update_notification(notif)
    @notif = notif
    @url = action_url(notif.item)
  end

  def action_state_update_notification(user, notif, _data = nil)
    call(user, ACTION_STATE_UPDATE, :plain) do
      handle_action_state_update_notification(notif)
    end
  end

  def action_state_update_notification_crypted(user, notif, _data = nil)
    call(user, ACTION_STATE_UPDATE, :crypted) do
      handle_action_state_update_notification(notif)
    end
  end

  ### New comment ###
  def handle_comment_creation_notification(notif)
    @notif = notif
    @url = action_url(notif.item.action)
  end

  def comment_creation_notification(user, notif, _data = nil)
    call(user, COMMENT_CREATION, :plain) do
      handle_comment_creation_notification(notif)
    end
  end

  def comment_creation_notification_crypted(user, notif, _data = nil)
    call(user, COMMENT_CREATION, :crypted) do
      handle_comment_creation_notification(notif)
    end
  end

  ### Export generated ###
  def handle_export_generation_notification(notif)
    @notif = notif
    @url = report_exports_url(notif.item.report)
  end

  def export_generation_notification(user, notif, _data = nil)
    call(user, EXPORT_GENERATION, :plain) do
      handle_export_generation_notification(notif)
    end
  end

  def export_generation_notification_crypted(user, notif, _data = nil)
    call(user, EXPORT_GENERATION, :crypted) do
      handle_export_generation_notification(notif)
    end
  end

  ### Scan created ###

  def handle_default_notification(notif)
    @notif = notif
    @url = notif.data[:path]
  end

  def scan_created_notification(user, notif, _data = nil)
    call(user, SCAN_CREATED, :plain) do
      handle_default_notification(notif)
    end
  end

  def scan_created_notification_crypted(user, notif, _data = nil)
    call(user, SCAN_CREATED, :crypted) do
      handle_default_notification(notif)
    end
  end

  ### Scan destroyed ###

  def scan_destroyed_notification(user, notif, _data = nil)
    call(user, SCAN_DESTROYED, :plain) do
      handle_default_notification(notif)
    end
  end

  def scan_destroyed_notification_crypted(user, notif, _data = nil)
    call(user, SCAN_DESTROYED, :crypted) do
      handle_default_notification(notif)
    end
  end

  ### Scan launched done ###

  def scan_launch_done_notification(user, notif, _data = nil)
    call(user, SCAN_LAUNCH_DONE, :plain) do
      handle_default_notification(notif)
    end
  end

  def scan_launch_done_notification_crypted(user, notif, _data = nil)
    call(user, SCAN_LAUNCH_DONE, :crypted) do
      handle_default_notification(notif)
    end
  end

  private

  # @see ApplicationMailer and devise.config.mailer_sender
  def call(user, subject, mode = :plain, opts = {})
    change_locale(user)
    @user = user
    yield
    email = select_email(@user)
    gpg_h = { sign: true } # with user.public_key
    if mode == :crypted
      gpg_h[:encrypt] = true # with gpg private key corresponding to ACTION_EMAIL
      gpg_h[:keys] = { email => @user.public_key }
    end
    mail_h = { to: email, subject: I18n.t(subject), gpg: gpg_h }
    mail_h.merge!(opts)
    mail(mail_h)
  end

  # Use notification email if present
  def select_email(user)
    user.notification_email.presence || user.email
  end

  # Si l'utilisateur a une langue définie, on l'utilise, sinon la langue utilisée actuellement
  def change_locale(user)
    I18n.locale = user.language.iso if user.language.present?
  end
end
