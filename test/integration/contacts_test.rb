# frozen_string_literal: true

require 'test_helper'

class ContactsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list contacts' do
    get contacts_path
    check_not_authenticated
  end

  test 'unauthenticated cannot consult contacts' do
    contact = User.contacts.first
    get "/contacts/#{contact.id}"
    check_not_authenticated
  end

  test 'unauthenticated cannot know if a contact exists' do
    get '/contacts/ABC'
    check_not_authenticated
  end

  test 'authenticated staff can list contacts' do
    sign_in users(:staffuser)
    get contacts_path
    assert_select 'main table.table' do
      User.contacts.page(1).each do |contact|
        assert_select 'td a .username', text: contact.full_name
        assert_select 'td', text: contact.email
      end
    end
  end

  test 'authenticated staff can filter contacts by email containing' do
    sign_in users(:staffuser)
    get contacts_path, params: { q: { email_cont: 'tin' } }
    assert_select 'main table.table' do
      assert_select 'td a .username', text: 'MATIN Martin'
      assert_select 'td a .username', text: 'PANTIN Rachel'
      assert_select 'td a .username', text: 'BOUVET Léa', count: 0
    end
  end

  test 'authenticated staff can filter contacts by full name containing' do
    sign_in users(:staffuser)

    get contacts_path, params: { q: { full_name_cont: 'TIN' } }
    assert_select 'main table.table' do
      assert_select 'td a .username', text: 'MATIN Martin'
      assert_select 'td a .username', text: 'PANTIN Rachel'
      assert_select 'td a .username', text: 'BOUVET Léa', count: 0
    end
  end

  test 'authenticated staff can view contact' do
    sign_in users(:staffuser)
    contact = User.contacts.first
    get "/contacts/#{contact.id}"
    assert_select 'h4', text: contact.full_name
  end

  test 'authenticated staff cannot consult inexistant contact' do
    sign_in users(:staffuser)
    get '/contacts/ABC'
    check_unscoped
  end

  test 'authenticated staff contact_admin can activate contact account' do
    sign_in users(:staffuser)
    contact = User.contacts.inactif.first
    assert_equal 'inactif', User.contacts.find(contact.id).state
    put activate_contact_path(contact), params: {}
    assert_equal 'actif', User.contacts.find(contact.id).state
  end

  test 'unauthenticated cannot activate contact account' do
    contact = User.contacts.inactif.first
    assert_equal 'inactif', User.contacts.find(contact.id).state
    put activate_contact_path(contact), params: {}
    assert_equal 'inactif', User.contacts.find(contact.id).state
    check_not_authenticated
  end

  test 'authenticated staff contact_admin can resend instructions to reset contact password' do
    sign_in users(:staffuser)
    contact = User.contacts.actif.first
    assert User.contacts.find(contact.id).reset_password_sent_at.blank?
    post send_reset_password_contact_path(contact), params: {}
    assert User.contacts.find(contact.id).reset_password_sent_at.present?
    assert User.contacts.find(contact.id).reset_password_token.present?
  end

  test 'unauthenticated cannot resend instructions to reset contact password' do
    contact = User.contacts.actif.first
    assert User.contacts.find(contact.id).reset_password_sent_at.blank?
    post send_reset_password_contact_path(contact), params: {}
    assert User.contacts.find(contact.id).reset_password_sent_at.blank?
    assert User.contacts.find(contact.id).reset_password_token.blank?
    check_not_authenticated
  end

  test 'authenticated staff contact_admin can resend instructions to confirm contact account' do
    sign_in users(:staffuser)
    contact = User.contacts.actif.first
    contact.update(confirmed_at: nil)
    contact.send_confirmation_instructions
    first_token = User.contacts.find(contact.id).confirmation_token
    first_sent = User.contacts.find(contact.id).confirmation_sent_at
    put resend_confirmation_contact_path(contact), params: {}
    # Devise utilise le même token si présent (car valide seulement sur une durée)
    # la date d'envoi est générée en même temps que le token
    assert_equal User.contacts.find(contact.id).confirmation_token, first_token
    assert_equal User.contacts.find(contact.id).confirmation_sent_at, first_sent
  end

  test 'unauthenticated cannot resend instructions to confirm contact account' do
    contact = User.contacts.actif.first
    assert_not User.contacts.find(contact.id).pending_reconfirmation?
    put resend_confirmation_contact_path(contact), params: {}
    check_not_authenticated
    assert_not User.contacts.find(contact.id).pending_reconfirmation?
  end

  test 'authenticated staff contact_admin can deactivate contact account' do
    sign_in users(:staffuser)
    contact = User.contacts.actif.first
    assert_equal 'actif', User.contacts.find(contact.id).state
    put deactivate_contact_path(contact), params: {}
    assert_equal 'inactif', User.contacts.find(contact.id).state
  end

  test 'unauthenticated cannot deactivate contact account' do
    contact = User.contacts.actif.first
    assert_equal 'actif', User.contacts.find(contact.id).state
    put deactivate_contact_path(contact), params: {}
    assert_equal 'actif', User.contacts.find(contact.id).state
    check_not_authenticated
  end

  test 'authenticated contact can list actives actions' do
    sign_in users(:c_one)
    get actions_path
    assert_select 'main table.table' do
      Action.where(receiver: users(:c_one)).active.to_correct.each do |action|
        assert_select 'td', text: action.name
        assert_select 'td', text: action.receiver.full_name
      end
    end
  end

  test 'authenticated contact can list clotured actions' do
    sign_in users(:c_one)
    get clotured_actions_path
    assert_select 'main table.table' do
      Action.where(receiver: users(:c_one)).clotured.to_correct.each do |action|
        assert_select 'td', text: action.name
        assert_select 'td', text: action.receiver.full_name
      end
    end
  end

  test 'authenticated contact can list archived actions' do
    sign_in users(:c_one)
    get archived_actions_path
    assert_select 'main table.table' do
      Action.where(receiver: users(:c_one)).archived.to_correct.each do |action|
        assert_select 'td', text: action.name
        assert_select 'td', text: action.receiver.full_name
      end
    end
  end

  test 'authenticated contact can filter actives actions by name containing' do
    sign_in users(:c_one)
    get actions_path, params: { q: { name_cont: '3' } }
    assert_select 'main table.table' do
      assert_select 'td', text: 'Action3', count: 1
      assert_select 'td', text: 'Action1', count: 0
    end
  end

  test 'authenticated contact can filter actives actions by client equal to' do
    filter_by_eq('aggregate_report_project_client_id')
  end

  test 'authenticated contact can filter actives actions by project equal to' do
    filter_by_eq('aggregate_report_project_id')
  end

  test 'authenticated contact can filter actives actions by report equal to' do
    filter_by_eq('aggregate_report_id')
  end

  test 'authenticated contact can filter actives actions by aggregate equal to' do
    filter_by_eq('aggregate_id')
  end

  test 'authenticated contact can filter actives actions by status equal to' do
    filter_by_eq('state')
  end

  test 'authenticated contact can filter actives actions by meta-status equal to' do
    filter_by_eq('meta_state')
  end

  test 'authenticated contact can view own action' do
    sign_in users(:c_one)
    a = Action.where(receiver: users(:c_one)).first
    get "/actions/#{a.id}"
    assert_select 'h4', text: a.name
  end

  # + les actions à corriger des équipes de remédiation propriétaires
  test 'authenticated contact cannot view action whom is not receiver nor in actions to correct of
        clients' do
    sign_in users(:c_one)
    a = action_to_correct_not_in_contact_scope(users(:c_one))
    get "/actions/#{a.id}", headers: { 'HTTP_REFERER' => root_path }
    assert_redirected_to root_path
  end

  test 'authenticated contact cannot consult inexistant action' do
    sign_in users(:c_one)
    get '/actions/ABC', headers: { 'HTTP_REFERER' => root_path }
    assert_redirected_to root_path
  end

  test 'authenticated contact cannot update action' do
    sign_in users(:c_one)
    a = Action.where(receiver: users(:c_one)).first
    put "/actions/#{a.id}", params:
      {
        act:
        {
          name: 'test',
          description: a.description,
          aggregate_ids: a.aggregate_ids
        }
      }
    assert_redirected_to root_url
  end

  test 'authenticated contact cannot update non-existent action' do
    sign_in users(:c_one)
    put '/actions/ABC', params:
    {
      act:
      {
        name: 'test',
        description: 'test',
        aggregate_id: '58ed1d83-12f1-4575-bbea-1537f8add561'
      }
    }
    assert_redirected_to root_url
  end

  test 'authenticated contact can comment action' do
    a = actions(:action_one)
    contact = "Ceci n'est pas un commentaire"
    sign_in users(:c_one)
    post "/actions/#{a.id}/comment", params:
      {
        comment:
        {
          comment: contact
        }
      }
    assert_equal contact, a.comments.order('created_at desc').first.comment
  end

  test 'authenticated contact can list dependencies' do
    sign_in users(:c_one)
    a = Action.where(receiver: users(:c_one)).detect { |act| act.dependencies.present? }
    a = Dependency.find((a.dependencies.ids | a.roots.ids).first).action_s
    get action_dependencies_path(a)
    assert_select 'main table.table' do
      a.action_p.each do |action|
        assert_select 'td', text: action.name
        assert_select 'td', text: action.receiver.full_name
      end
    end
  end

  test 'authenticated contact can list statistics' do
    sign_in users(:c_one)
    get statistics_path
    assert_response :success
  end

  test 'authenticated contact can filter reports by title containing' do
    sign_in users(:c_one)
    get reports_path, params: { q: { title_cont: 'unused value' } }
    assert_select 'main table.table' do
      assert_select 'td', text: 'Hospiville', count: 0
      assert_select 'td', text: 'MaPUI', count: 0
    end
  end

  test 'authenticated contact can view project statistics' do
    sign_in users(:c_one)
    p = User.contacts.where(ref_identifier: 'SELLSY_1000').first.contact_projects.first
    get "/projects/#{p.id}/statistics"
    assert_select 'h4', text: p.name
  end

  test 'authenticated contact cannot consult inexistant statistics' do
    sign_in users(:c_one)
    get '/projects/ABC/statistics'
    assert_redirected_to projects_path
  end

  test 'authenticated contact can update certificate' do
    sign_in users(:c_one)
    p = User.contacts.where(ref_identifier: 'SELLSY_1000').first.contact_projects.first
    l = Language.ids
    post "/projects/#{p.id}/statistics/update_certificate", params:
      {
        certificate:
        {
          transparency_level: 'clearness',
          language_ids: l
        }
      }
    updated_p = Project.find_by(id: p.id)
    assert_equal 'clearness', updated_p.certificate.transparency_level
  end

  test 'authenticated contact cannot update non-existent certificate' do
    sign_in users(:c_one)
    l = Language.ids
    post '/projects/ABC/statistics/update_certificate', params:
    {
      certificate:
      {
        transparency_level: '2',
        language_ids: l
      }
    }
    assert_redirected_to projects_path
  end

  test 'unauthenticated can view the login page' do
    get login_path
    assert 200
  end

  test 'unauthenticated active contact can login' do
    contact = User.contacts.actif.find_by(full_name: 'DURANT Jean')
    post login_path, params:
      {
        user:
          {
            email: contact.email,
            password: 'P@ssW0rdLongEnough'
          }
      }
    assert_redirected_to root_path
  end

  test 'unauthenticated inactive contact cannot login' do
    contact = User.contacts.inactif.first
    post login_path, params:
      {
        user:
          {
            email: contact.email,
            password: 'P@ssW0rdLongEnough'
          }
      }
    assert_equal I18n.t('devise.failure.invalid',
      authentication_keys: I18n.t('activerecord.attributes.user.email')), flash[:alert]
  end

  test 'authenticated can logout' do
    user = users(:c_one)
    sign_in user
    delete logout_path
    check_not_authenticated
  end

  test 'unauthenticated contact can view signup if a token was received' do
    # DEVISE internal
  end

  test 'unauthenticated contact cannot view signup if no token was received' do
    # DEVISE internal
  end

  test 'unauthenticated contact can create password if a token was received' do
    # DEVISE internal
  end

  test 'unauthenticated contact cannot create password if passwords are different' do
    # DEVISE internal
  end

  test 'unauthenticated contact cannot create password if password have wrong format' do
    # DEVISE internal
  end

  test 'unauthenticated contact cannot create password if a token was not received' do
    # DEVISE internal
  end

  test 'authenticated contact cannot delete multiple actions at once' do
    sign_in users(:c_one)
    a = Action.where(receiver: users(:c_one)).first
    a2 = Action.where(receiver: users(:c_one)).last
    post '/actions/updates', headers: { 'HTTP_REFERER' => root_path }, params:
      {
        do: 'delete',
        choice: [a.id, a2.id]
      }
    assert Action.find([a.id, a2.id]).present?
  end

  test 'authenticated contact cannot send mail' do
    sign_in users(:c_one)
    a = Action.where(receiver: users(:c_one)).first
    post '/actions/updates', headers: { 'HTTP_REFERER' => root_path }, params:
      {
        do: 'mail',
        choice: [a.id]
      }
    assert_equal I18n.t('actions.notices.no_rights'), flash[:alert]
  end

  test 'authenticated contact can update multiple actions at once if 1<do<7' do
    sign_in users(:c_one)
    a = Action.where(state: 3, receiver: users(:c_one)).first
    a2 = Action.where(state: 3, receiver: users(:c_one)).last
    post '/actions/updates', headers: { 'HTTP_REFERER' => root_path }, params:
      {
        do: 'assigned',
        choice: [a.id, a2.id]
      }
    assert Action.assigned.find([a.id, a2.id]).present?
  end

  test 'authenticated contact cannot update multiple actions at once if not 1<do<7' do
    sign_in users(:c_one)
    a = Action.where(state: 3, receiver: users(:c_one)).first
    a2 = Action.where(state: 3, receiver: users(:c_one)).last
    post '/actions/updates', headers: { 'HTTP_REFERER' => root_path }, params:
      {
        do: 'reviewed_fix',
        choice: [a.id, a2.id]
      }
    assert_equal I18n.t('actions.notices.no_rights'), flash[:alert]
  end

  test 'authenticated contact can only bulk update scoped actions' do
    sign_in users(:c_one)
    a = Action.where(state: 3, receiver: users(:c_one)).first
    a2 = action_to_correct_not_in_contact_scope(users(:c_one))
    post '/actions/updates', headers: { 'HTTP_REFERER' => root_path }, params:
      {
        do: 'not_fixed',
        choice: [a.id, a2.id]
      }
    # On check que l'on a modifié que a et non a2
    a.reload
    a2.reload
    assert_equal :not_fixed.to_s, a.state
    assert_equal :fixed_vulnerability.to_s, a2.state
  end

  test 'authenticated contact cannot delete report-export' do
    sign_in users(:c_one)
    export = report_exports(:report_export_one)
    delete export_path(export)
    check_not_authorized
  end

  test 'authenticated contact cannot export classic report' do
    sign_in users(:c_one)
    report = scan_reports(:mapui)
    post report_exports_path(report)
    check_not_authorized
  end

  test 'authenticated contact cannot export without architecture report' do
    sign_in users(:c_one)
    report = scan_reports(:mapui)
    post report_exports_path(report), params:
      {
        archi: false
      }
    check_not_authorized
  end

  test 'authenticated contact can list his reports' do
    sign_in users(:c_one)
    get '/reports'
    assert_response :success
  end

  test 'authenticated contact can see his home page' do
    sign_in users(:c_one)
    get root_path
    assert_response :success
  end

  test 'unauthenticated cannot create contact' do
    post contacts_path, params:
    {
      contact:
      {
        ref_identifier: 7357,
        full_name: 'test',
        email: 'test@test.test'
      }
    }
    check_not_authenticated
  end

  test 'authenticated staff can create contact' do
    sign_in users(:staffuser)
    client = Client.first
    post contacts_path, params:
    {
      contact:
      {
        ref_identifier: 7357,
        full_name: 'test',
        email: 'test@test.test',
        contact_client_ids: [client.id]
      }
    }
    new_user = User.contacts.find_by(full_name: 'test')
    assert_not_nil new_user
    assert_redirected_to contact_path(new_user)
    get contact_path(new_user)
    assert_response 200
  end

  test 'unauthenticated cannot view new contact form' do
    get new_contact_path
    check_not_authenticated
  end

  test 'unauthenticated cannot view edit contact form' do
    get edit_contact_path(User.contacts.first)
    check_not_authenticated
  end

  test 'unauthenticated cannot update contact' do
    put contact_path(User.contacts.first), params:
    {
      contact:
      {
        full_name: 'update',
        email: 'update@test.test'
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot destroy contact' do
    delete contact_path(User.contacts.first)
    check_not_authenticated
  end

  test 'authenticated staff can view new contact form' do
    sign_in users(:staffuser)
    get new_contact_path
    assert_response :success
  end

  test 'authenticated staff can view edit contact form' do
    sign_in users(:staffuser)
    get edit_contact_path(User.contacts.first)
    assert_response :success
  end

  test 'authenticated staff can update contact' do
    sign_in users(:staffuser)
    new_email = 'update@test.test'
    identifier = 'freoughreoghor'
    contact = User.contacts.first
    put contact_path(contact), params:
    {
      contact:
      {
        full_name: 'update',
        email: new_email,
        notification_email: new_email,
        ref_identifier: identifier,
        contact_client_ids: [clients(:client_one).id],
        role_ids: [roles(:contact_admin_contact).id]
      }
    }
    assert_redirected_to contact_path(contact)
    assert_not_nil User.contacts.find_by(full_name: 'update')
    assert_equal new_email, User.contacts.find_by(full_name: 'update').unconfirmed_email
    assert_equal new_email, User.contacts.find_by(full_name: 'update').notification_email
    assert_equal identifier, User.contacts.find_by(full_name: 'update').ref_identifier
    assert_equal(
      clients(:client_one).id, User.contacts.find_by(full_name: 'update').contact_clients.first.id
    )
    assert_equal(
      roles(:contact_admin_contact), User.contacts.find_by(full_name: 'update').roles.first
    )
  end

  test 'authenticated staff can destroy contact member' do
    sign_in users(:staffuser)
    delete contact_path(User.contacts.first)
    assert_equal flash[:notice], I18n.t('users.notices.deletion_success')
  end

  test 'authenticated staff cannot create new contact without full_name' do
    sign_in users(:staffuser)
    post contacts_path, params:
    {
      contact:
      {
        email: 'test@test.test'
      }
    }
    assert_response(200)
  end

  test 'authenticated staff cannot create new contact without email' do
    sign_in users(:staffuser)
    post contacts_path, params:
    {
      contact:
      {
        full_name: 'test'
      }
    }
    assert_response(200)
  end

  test 'authenticated staff cannot update contact without full_name' do
    sign_in users(:staffuser)
    put contact_path(User.contacts.first), params:
    {
      contact:
      {
        full_name: nil,
        email: 'test@test.test'
      }
    }
    assert_response(200)
  end

  test 'authenticated staff cannot update contact without email' do
    sign_in users(:staffuser)
    put contact_path(User.contacts.first), params:
    {
      contact:
      {
        full_name: 'test',
        email: nil
      }
    }
    assert_response(200)
  end

  # 2FA
  test 'unauthenticated cannot force_mfa on a contact' do
    put force_mfa_user_path(User.contacts.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can force_mfa on a contact only if not already forced' do
    contact = User.contacts.first
    assert_not(contact.otp_mandatory?)
    sign_in users(:staffuser)
    put force_mfa_user_path(contact)
    check_not_authorized # Not superadmin
    sign_in users(:superadmin)
    put force_mfa_user_path(contact)
    assert_redirected_to root_path # back in history
    assert(contact.reload.otp_mandatory?)
  end

  test 'unauthenticated cannot unforce_mfa on a contact' do
    put unforce_mfa_user_path(User.contacts.first)
    check_not_authenticated
  end

  test 'authenticated super_admin only can unforce_mfa on a contact only if already forced' do
    contact = User.contacts.first
    assert_not(contact.otp_mandatory?)
    sign_in users(:staffuser)
    put unforce_mfa_user_path(contact)
    check_not_authorized # Not superadmin
    sign_in users(:superadmin)
    put unforce_mfa_user_path(contact)
    check_not_authorized
    put force_mfa_user_path(contact)
    assert_redirected_to root_path # back in history
    assert(contact.reload.otp_mandatory?)
    put unforce_mfa_user_path(contact)
    assert_redirected_to root_path # back in history = last get
    assert_not(contact.reload.otp_mandatory?)
  end

  test 'authenticated admin can edit a current staff as contact if member of contact group' do
    user = User.contacts.first
    sign_in users(:superadmin)
    group = groups(:staff)
    assert_not(user.in?(group.users))
    get edit_staff_path(user)
    check_unscoped
    post add_user_to_group_path(group, user)
    assert(user.in?(group.users))
    get edit_staff_path(user)
    assert_response :success
  end

  private

  def filter_by_eq(key)
    sign_in users(:c_one)
    get actions_path, params: { q: { "#{key}_eq": '' } }
    assert_select 'main table.table' do
      assert_select 'td', text: 'Action3', count: 1
      assert_select 'td', text: 'Action1', count: 1
    end
  end

  def action_to_correct_not_in_contact_scope(user)
    # Not in user scope:
    # As a contact:
    # Les actions à corriger du user (en tant que receiver)
    # ids = user.received_actions.to_correct.ids
    # + les actions à corriger des équipes de remédiation propriétaires
    # ids |= user.contact_clients.clients.flat_map { |c| c.actions.to_correct.ids }
    actions_to_correct_of_linked_clients = user.contact_clients.clients.flat_map do |cli|
      cli.actions.to_correct.ids
    end
    Action.where(state: 3).where.not(receiver: user)
          .where.not(id: actions_to_correct_of_linked_clients).first
  end
end
