# frozen_string_literal: true

module ContactConcern
  extend ActiveSupport::Concern

  included do
    has_many :contact_client_contacts,
      class_name: 'ClientContact',
      foreign_key: :contact_id,
      inverse_of: :contact,
      dependent: :delete_all

    has_many :contact_clients, through: :contact_client_contacts, source: :client
    has_many :contact_kept_clients, -> { kept }, through: :contact_client_contacts, source: :client
    has_many :contact_projects, through: :contact_clients, source: :projects
    has_many :contact_assets, -> { distinct }, through: :contact_projects, source: :assets
    has_many :contact_targets, -> { distinct }, through: :contact_assets, source: :targets
    has_many :contact_projects_staffs, through: :contact_projects, source: :staffs
    has_many :contact_kept_projects, -> { kept }, through: :contact_kept_clients, source: :projects
    has_many :contact_colleagues, -> { distinct }, through: :contact_clients, source: :contacts
    has_many :contact_viewable_reports, through: :contact_projects, source: :reports
    has_many :contact_viewable_exports, through: :contact_viewable_reports, source: :exports

    has_many :received_actions,
      class_name: 'Action',
      inverse_of: :receiver,
      foreign_key: :receiver_id,
      primary_key: :id,
      dependent: :nullify

    has_many :report_contacts,
      class_name: 'ReportContact',
      foreign_key: :contact_id,
      inverse_of: :contact,
      dependent: :delete_all

    has_many :reports,
      through: :report_contacts,
      source: :report

    def contact_client_owner?
      contact? && contact_clients.kept.any? { |cli| cli.projects.count.positive? }
    end
  end
end
