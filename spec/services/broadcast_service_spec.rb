# frozen_string_literal: true

require 'rails_helper'

def create_new_version(user)
  PaperTrail::Version.create!(
    item_type: 'VmScan',
    item_id: VmScan.first.id,
    event: 'create',
    whodunnit: user.id
  )
end

RSpec.describe BroadcastService do
  fixtures :all

  describe 'notify a user' do
    context 'with some google chat configs linked to send msg to configured channel' do
      it 'does send a msg for each gcc' do
        # GIVEN a user associated with a google chat config
        user = users(:staffuser)
        user.update(send_mail_on: [], notify_on: [])
        # Create 2 accounts_users
        AccountUser.create!(
          account: google_chat_configs(:google_chat_config_one),
          user_id: user.id
        )
        AccountUser.create!(
          account: google_chat_configs(:google_chat_config_two),
          user_id: user.id
        )
        assert_equal 2, user.usable_google_chat_configs.count
        subject = Notification.subjects.keys.first
        version = create_new_version(user)
        expect(Faraday).to receive(:post).twice
        # WHEN calling notify
        BroadcastService.notify([user], subject, version)
        # THEN expectations are checked
      end
    end

    context 'with some microsoft teams configs linked to send msg to configured channel' do
      it 'does send a msg for each mtc' do
        # GIVEN a user associated with a microsoft teams config
        user = users(:staffuser)
        user.update(send_mail_on: [], notify_on: [])
        # Create 2 accounts_users
        AccountUser.create!(
          account: microsoft_teams_configs(:microsoft_teams_config_one),
          user_id: user.id
        )
        AccountUser.create!(
          account: microsoft_teams_configs(:microsoft_teams_config_two),
          user_id: user.id
        )
        assert_equal 2, user.usable_microsoft_teams_configs.count
        subject = Notification.subjects.keys.first
        version = create_new_version(user)
        expect(Faraday).to receive(:post).twice
        # WHEN calling notify
        BroadcastService.notify([user], subject, version)
        # THEN expectations are checked
      end
    end

    context 'with some zoho cliq configs linked to send msg to configured channel' do
      it 'does send a msg for each zcc' do
        # GIVEN a user associated with a zoho cliq config
        user = users(:staffuser)
        user.update(send_mail_on: [], notify_on: [])
        # Create 2 accounts_users
        AccountUser.create!(
          account: zoho_cliq_configs(:zoho_cliq_config_one),
          user_id: user.id
        )
        AccountUser.create!(
          account: zoho_cliq_configs(:zoho_cliq_config_two),
          user_id: user.id
        )
        assert_equal 2, user.usable_zoho_cliq_configs.count
        subject = Notification.subjects.keys.first
        version = create_new_version(user)
        expect(Faraday).to receive(:post).twice
        # WHEN calling notify
        BroadcastService.notify([user], subject, version)
        # THEN expectations are checked
      end
    end
  end
end
