class AddUsersTable < ActiveRecord::Migration[6.0]
  def up
    # CREATE USERS
    create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string "full_name", null: false
      t.string "email", null: false
      t.string "notification_email"
      t.string "password_digest"
      t.text "public_key"
      t.integer "state", default: 0
      t.string "token"
      t.uuid "language_id"
      t.string "default_view"
      t.string "ref_identifier" # For future directories imports
      t.integer "internal_id"
      t.string "avatar_url"
      # Rememberable
      t.datetime "remember_created_at"
      ## Trackable
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet "current_sign_in_ip"
      t.inet "last_sign_in_ip"
      ## OAuth
      t.string "provider"
      t.string "uid"
      # MONITORING
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "discarded_at"
      t.index ["discarded_at"], name: "index_users_on_discarded_at"
      t.index ["email"], name: "index_users_on_email", unique: true
      # MTI, type is nullable for directories imports
      t.string :type
    end

    # CREATE USERS_ROLES
    create_table :users_roles, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid :user_id, null: false
      t.uuid :role_id, null: false
    end
    add_foreign_key :users_roles, :users, column: :user_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :users_roles, :roles, column: :role_id, primary_key: :id, on_delete: :cascade
    add_index(:users_roles, [ :user_id, :role_id ])

    # CREATE GROUPS TABLE
    create_table "groups", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string "name", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["name"], name: 'index_groups_on_name', unique: true
    end

    # We create 2 actual groups
    staffs_grp = Group.create!(name: 'staffs')
    contacts_grp = Group.create!(name: 'contacts')

    # CREATE USERS_GROUPS
    create_table "users_groups", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.uuid "user_id", null: false
      t.uuid "group_id", null: false
      t.string :dashboard_default_card, default: 'reports'
      t.index ["group_id", "user_id"], name: "index_users_groups_on_group_id_and_user_id", unique: true
    end

    add_foreign_key :users_groups, :users, column: :user_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :users_groups, :groups, column: :group_id, primary_key: :id, on_delete: :cascade

    # A role belongs to a group which has many roles
    rename_column :roles, :group, :group_int # group is a special sql word...
    add_column :roles, :group_id, :uuid
    add_foreign_key :roles, :groups, column: :group_id, primary_key: :id, on_delete: :nullify

    # Modify all roles to link to group
    Role.all.each do |role|
      say_with_time 'Updating roles groups' do
        ActiveRecord::Base.connection.execute("UPDATE roles SET group_id = '#{Group.staff.id}' WHERE group_int = 0")
        ActiveRecord::Base.connection.execute("UPDATE roles SET group_id = '#{Group.contact.id}' WHERE group_int = 1")
      end
    end

    remove_column :roles, :group_int
    remove_index :roles, [:name]
    remove_index :roles, ["name", "resource_type", "resource_id"]
    add_index :roles, [:name, :group_id], unique: true
    add_index :roles, [:name, :group_id, :resource_type, :resource_id], unique: true, name: 'index_roles_on_name_and_grp_id_and_res_type_and_res_id'

    # MOVE entries
    say_with_time 'Moving staffs to users table' do
      query = <<-SQL
        INSERT INTO users (id, full_name, email, notification_email, public_key, state, token, language_id,
          avatar_url, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, provider, uid,
          created_at, updated_at, discarded_at, type)
        SELECT id, full_name, email, notification_email, public_key, state, token, language_id, avatar_url, remember_created_at, sign_in_count,
          current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, provider, uid, created_at, updated_at, discarded_at, 'Staff'
        FROM staffs
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    say_with_time 'Moving staffs_roles to users_roles table' do
      query = <<-SQL
        INSERT INTO users_roles (user_id, role_id)
        SELECT staff_id, role_id
        FROM staffs_roles
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    say_with_time 'Adding staffs to Group.staff' do
      # All Staffs are added to staffs group
      query = <<-SQL
        INSERT INTO users_groups(group_id, user_id)
        SELECT
          (SELECT id FROM groups WHERE groups.name = 'staffs') as group_id,
          id as user_id
        FROM staffs
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    say_with_time 'Moving contacts to users table' do
      remove_foreign_key :clients_contacts, :contacts
      remove_foreign_key :reports_contacts, :contacts
      # Double comptes
      doubles_query = <<-SQL
        SELECT c.id as contact_id, c.internal_id, c.ref_identifier, c.password_digest, (SELECT u.id FROM users u WHERE u.email = c.email ) as user_id FROM contacts c WHERE c.email IN (SELECT email FROM users)
      SQL
      connection = ActiveRecord::Base.connection
      result = connection.exec_query(doubles_query)
      result.each do |row|
        say_with_time "Updating contact #{row} ids" do
          # On remplace tous les ids du contact par celui du user
          contact_id = row['contact_id']
          user_id = row['user_id']
          # contacts_roles.contact_id
          ActiveRecord::Base.connection.exec_query("INSERT INTO users_roles (user_id, role_id) SELECT '#{user_id}' as user_id, role_id FROM contacts_roles WHERE contact_id = '#{contact_id}'")
          ActiveRecord::Base.connection.exec_query("DELETE FROM contacts_roles WHERE contact_id = '#{contact_id}'")
          # clients_contacts.contact_id
          ActiveRecord::Base.connection.exec_query("UPDATE clients_contacts SET contact_id = '#{user_id}' WHERE contact_id = '#{contact_id}'")
          # reports_contacts.contact_id
          ActiveRecord::Base.connection.exec_query("UPDATE reports_contacts SET contact_id = '#{user_id}' WHERE contact_id = '#{contact_id}'")
          # action.receiver_id
          Action.where(receiver_id: contact_id).update(receiver_id: user_id)
          # On update les champs dédiés à contact
          User.where(id: user_id).update({internal_id: row['internal_id'], ref_identifier: row['ref_identifier'], password_digest: row['password_digest']})
          # On ajoute au groupe contacts
          UserGroup.create!(user_id: user_id, group_id: contacts_grp.id)
        end
      end

      # Comptes uniques
      query2 = <<-SQL
        INSERT INTO users (id, internal_id, ref_identifier, full_name, email, notification_email, password_digest, public_key, state, token, language_id, created_at, updated_at, discarded_at, type)
        SELECT id, internal_id, ref_identifier, full_name, email, notification_email, password_digest, public_key, state, token, language_id, created_at, updated_at, discarded_at, 'Contact'
        FROM contacts
        WHERE email NOT IN (SELECT email FROM users)
      SQL
      ActiveRecord::Base.connection.execute(query2)
    end
    say_with_time 'Moving contacts_roles to users_roles table' do
      query = <<-SQL
        INSERT INTO users_roles (user_id, role_id)
        SELECT contact_id, role_id
        FROM contacts_roles
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    say_with_time 'Adding contacts to Group.contact' do
      # All new users of type Contact are added to contacts group
      query = <<-SQL
        INSERT INTO users_groups(group_id, user_id)
        SELECT
          (SELECT id FROM groups WHERE groups.name = 'contacts') as group_id,
          id as user_id
        FROM users
        WHERE type = 'Contact'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end

    # UPDATE foreign_keys
    say_with_time 'Updating staffs foreign_keys' do
      # staffs
      remove_foreign_key :reports, :staffs
      add_foreign_key :reports, :users, column: :staff_id, on_delete: :cascade
      remove_foreign_key :report_exports, :staffs
      add_foreign_key :report_exports, :users, column: "exporter_id", on_delete: :restrict
      remove_foreign_key :staffs_roles, :staffs
      remove_foreign_key :staffs_teams, :staffs
      add_foreign_key :staffs_teams, :users, column: :staff_id, on_delete: :cascade
    end
    say_with_time 'Updating contacts foreign_keys' do
      # contacts
      add_foreign_key :clients_contacts, :users, column: :contact_id, on_delete: :cascade
      remove_foreign_key :contacts_roles, :contacts
      add_foreign_key :reports_contacts, :users, column: :contact_id, on_delete: :cascade
    end

    # Delete staffs and contact tables
    drop_table :staffs
    drop_table :contacts
    drop_table :staffs_roles
    drop_table :contacts_roles
  end

  def down
    create_table "contacts_roles", id: false, force: :cascade do |t|
      t.uuid "contact_id", null: false
      t.uuid "role_id", null: false
      t.index ["contact_id", "role_id"], name: "index_contacts_roles_on_contact_id_and_role_id", unique: true
    end
    add_foreign_key :contacts_roles, :contacts, column: :contact_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :contacts_roles, :roles, column: :role_id, primary_key: :id, on_delete: :cascade
    add_index(:contacts_roles, [ :contact_id, :role_id ])
    create_table "staffs_roles", id: false, force: :cascade do |t|
      t.uuid "staff_id", null: false
      t.uuid "role_id", null: false
      t.index ["staff_id", "role_id"], name: "index_staffs_roles_on_staff_id_and_role_id", unique: true
    end
    add_foreign_key :staffs_roles, :staffs, column: :staff_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :staffs_roles, :roles, column: :role_id, primary_key: :id, on_delete: :cascade
    add_index(:staffs_roles, [ :staff_id, :role_id ])
    # Re-create tables staffs and contacts
    create_table "staffs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string "email", null: false
      t.string "full_name", null: false
      t.string "avatar_url"
      t.datetime "remember_created_at"
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet "current_sign_in_ip"
      t.inet "last_sign_in_ip"
      t.string "provider"
      t.string "uid"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.uuid "language_id"
      t.integer "state", default: 0
      t.string "token"
      t.datetime "discarded_at"
      t.string "notification_email"
      t.text "public_key"
      t.string "default_view"
      t.index ["discarded_at"], name: "index_staffs_on_discarded_at"
      t.index ["email"], name: "index_staffs_on_email", unique: true
    end

    create_table "contacts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string "full_name"
      t.string "email", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.text "public_key"
      t.string "password_digest"
      t.integer "state", default: 0
      t.string "token"
      t.uuid "language_id"
      t.datetime "discarded_at"
      t.string "notification_email"
      t.integer "internal_id"
      t.string "ref_identifier"
      t.string "default_view"
      t.index ["discarded_at"], name: "index_contacts_on_discarded_at"
      t.index ["email"], name: "index_contacts_on_email", unique: true
    end
    # move
    say_with_time 'Moving users to staffs table' do
      query = <<-SQL
        INSERT INTO staffs (id, full_name, email, notification_email, public_key, state, token, language_id, default_view,
          avatar_url, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, provider, uid,
          created_at, updated_at, discarded_at)
        SELECT id, full_name, email, notification_email, public_key, state, token, language_id, default_view, avatar_url, remember_created_at, sign_in_count,
          current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, provider, uid, created_at, updated_at, discarded_at
        FROM users
        WHERE type = 'Staff'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    say_with_time 'Moving users_roles to staffs_roles table' do
      query = <<-SQL
        INSERT INTO staffs_roles (staff_id, role_id)
        SELECT user_id, role_id
        FROM users_roles
        LEFT JOIN users ON users_roles.user_id = users.id
        WHERE users.type = 'Staff'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    say_with_time 'Moving users to contacts table' do
      query1 = <<-SQL
        INSERT INTO contacts (id, internal_id, ref_identifier, full_name, email, notification_email, password_digest, public_key, state, token, language_id, default_view, created_at, updated_at, discarded_at, type)
        SELECT id, internal_id, ref_identifier, full_name, email, notification_email, password_digest, public_key, state, token, language_id, default_view, created_at, updated_at, discarded_at, 'Contact'
        FROM users
        WHERE type = 'Contact'
      SQL
      ActiveRecord::Base.connection.execute(query1)
    end
    say_with_time 'Moving contacts_roles to users_roles table' do
      query = <<-SQL
        INSERT INTO contacts_roles (contact_id, role_id)
        SELECT user_id, role_id
        FROM users_roles
        LEFT JOIN users ON users_roles.user_id = users.id
        WHERE users.type = 'Contact'
      SQL
      ActiveRecord::Base.connection.execute(query)
    end

    # UPDATE foreign_keys
    say_with_time 'Updating staffs foreign_keys' do
      # staffs
      remove_foreign_key :reports, :users
      add_foreign_key :reports, :staffs, on_delete: :cascade
      remove_foreign_key :report_exports, :users
      add_foreign_key :report_exports, :staffs, column: "exporter_id", on_delete: :restrict
      remove_foreign_key :staffs_teams, :staffs
      add_foreign_key :staffs_teams, :staffs, on_delete: :cascade
    end
    say_with_time 'Updating contacts foreign_keys' do
      # contacts
      remove_foreign_key :clients_contacts, :users
      add_foreign_key :clients_contacts, :contacts, on_delete: :cascade
      remove_foreign_key :reports_contacts, :users
      add_foreign_key :reports_contacts, :contacts, on_delete: :cascade
    end

    # Delete table users
    drop_table :users
    remove_foreign_key :users_roles, :users
    remove_foreign_key :users_roles, :roles
    drop_table :users_roles
  end
end
