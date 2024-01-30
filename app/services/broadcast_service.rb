# frozen_string_literal: true

class BroadcastService
  extend CableReady::Broadcaster

  class << self
    # Broadcast job progress to all job subscribers
    def broadcast_job_progress(job)
      users = trim_users(job.subscribers)
      users.each do |user|
        JobRefresher.refresh_user_running_jobs(user, job)
      end
    end

    # @param **subject:** Notification subject used to check if user wants mail notification
    # @param **user:** Notification subscriber
    # @param **notif:** Notification
    # @param **additional_data:** Defaults to {}, used to add more informations
    def handle_mail_notification(subject, user, notif, additional_data)
      # Envoi de mail si configuré
      return unless subject.to_s.in?(user.send_mail_on)

      Rails.logger.info("Mailing notification #{notif} to #{user} for #{subject}")
      # Chiffré si public_key configurée
      crypted = user.public_key? ? '_crypted' : ''
      UserMailer.send(:"#{subject}_notification#{crypted}", user, notif, additional_data)
                .deliver_later
    end

    # @param **subject:** Notification subject used to check if user wants notification
    # @param **user:** Notification subscriber
    # @param **notif:** Notification
    def handle_in_app_notification(subject, user, notif)
      # Envoi de notification si configuré
      return unless subject.to_s.in?(user.notify_on)

      Rails.logger.info("Broadcasting notification #{notif} to #{user} for #{subject}")
      NotificationRefresher.append_new_notif_to_user_subs_list(user, notif)
    end

    # Send notification to all user Slack like accounts uniq channels
    # @param **subject:** Subject to notify
    # @param **user:** User to notify
    # @param **notif:** Notification data
    # @param **sent_list:** Already sent tuples of [provider, channel_id]
    def handle_channels_notification(subject, user, notif, sent_list)
      user.accounts_users.each do |account_user|
        sent_list = handle_channel_notification(subject, account_user, notif, sent_list)
      end
    end

    # Send notification to account_user.channel_id if not already sent and
    # user has notify_on for subject
    # @param **subject:** Subject to notify
    # @param **account_user:** Slack like account and user data
    # @param **notif:** Notification data
    # @param **sent_list:** Already sent tuples of [provider, channel_id]
    # @return nothing if already sent or must not notify else sent_list << new_channel
    def handle_channel_notification(subject, account_user, notif, sent_list)
      provider = account_user.provider
      case provider
      when :slack
        # If no channel_id provided by user in profile we use default account channel_id
        channel_id = account_user.channel_id || account_user.account.channel_id
      when :google_chat, :microsoft_teams, :zoho_cliq
        channel_id = account_user.account.name
      else
        Rails.logger.info("Unknown provider: #{provider}")
      end
      new_channel = [provider, channel_id]
      Rails.logger.info(
        "#{new_channel} channel notification for #{subject}|#{account_user.notify_on} \
          || already sent list:#{sent_list}"
      )
      return sent_list if channel_id.blank? ||
                          !subject.to_s.in?(account_user.notify_on) ||
                          new_channel.in?(sent_list)

      uri = account_user.account.url
      ChannelProvider.send_msg(uri, provider, channel_id, notif)
      sent_list << new_channel
    end

    # Creates a notification and link it to its subscribers
    # Broadcast notification to all subscribers
    # And send mail if configured by subscriber
    # @param **users:** Subscribers
    # @param **subject:** Notification subject to check if mail must be sent too
    # @param **version:** PaperTrail::Version to create notification object from
    # @param **additional_data:** Hash containing data to be used in mails,
    # specific to each subject
    def notify(users, subject, version, additional_data = {})
      users = trim_users(users)
      notif = Notification.create!(version: version, subscribers: users, subject: subject)
      sent_list = []
      users.each do |user|
        # Here we could use threads to parallelize process?
        handle_in_app_notification(subject, user, notif)
        handle_mail_notification(subject, user, notif, additional_data)
        sent_list = handle_channels_notification(subject, user, notif, sent_list)
      end
    end

    private

    # @param **users:** Users enumeration to apply .compact.uniq on
    # @return users_array.compact.uniq
    def trim_users(users)
      # Each ne fonctionne que sur les types suivants, permet de passer un seul record.
      unless users.is_a?(Array) || users.is_a?(ActiveRecord::Associations::CollectionProxy)
        users = [users]
      end
      users.compact.uniq
    end
  end
end
