# frozen_string_literal: true

class JobSubscription < ApplicationRecord
  self.table_name = 'jobs_subscriptions'

  belongs_to :job,
    class_name: 'Job',
    inverse_of: :jobs_subscriptions,
    primary_key: :id

  belongs_to :subscriber,
    class_name: 'User',
    inverse_of: :jobs_subscriptions,
    primary_key: :id
end
