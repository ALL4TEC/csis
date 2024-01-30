# frozen_string_literal: true

# Service which aim is to destroy old jobs
class Cleaners::JobCleaner
  class << self
    def clear_all
      Job.old.destroy_all
    end
  end
end
