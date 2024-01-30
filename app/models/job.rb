# frozen_string_literal: true

#                   Modèle Job
#
# Le modèle Job permet d'informer les utilisateurs de l'application des
# jobs pour lesquels ils sont abonnés
class Job < ApplicationRecord
  validates :status, presence: true
  validates :resque_job_id, presence: true

  default_scope -> { order(created_at: :desc) }

  scope :recent, -> { where(['created_at > ?', 5.days.ago]) }
  scope :old, -> { where(['created_at < ?', 5.days.ago]) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[clazz created_at creator_id id progress_step progress_steps resque_job_id stacktrace status
       title updated_at]
  end

  belongs_to :creator,
    class_name: 'User',
    inverse_of: :created_jobs,
    primary_key: :id,
    optional: true

  has_many :jobs_subscriptions,
    class_name: 'JobSubscription',
    inverse_of: :job,
    primary_key: :id,
    dependent: :delete_all

  has_many :subscribers, through: :jobs_subscriptions

  # As not polymorphic
  has_one :scan_launch,
    class_name: 'ScanLaunch',
    inverse_of: :job,
    primary_key: :id,
    foreign_key: :csis_job_id,
    dependent: :nullify

  after_create do
    JobRefresher.add_to_list(self)
    BroadcastService.broadcast_job_progress(self) if subscribers.present?
  end

  after_update do
    JobRefresher.refresh(self)
    if saved_change_to_attribute?(:status)
      update(progress_step: progress_step + 1) unless status == 'error'
      BroadcastService.broadcast_job_progress(self) if subscribers.present?
    end
  end

  def errored?
    status == 'error'
  end
end
