# frozen_string_literal: true

module Kubernetes
  module JobCommon
    # The maximum number of workers to autoscale the job to.
    #
    # While the number of active Kubernetes Jobs is less than this number,
    # the gem will add new Jobs to auto-scale the workers.
    #
    # By default, this returns `Resque::Kubernetes.max_workers` from the gem
    # configuration. You may override this method to return any other value,
    # either as a simple integer or with some complex logic.
    #
    # Example:
    #    def max_workers
    #      # A simple integer
    #      105
    #    end
    #
    # Example:
    #    def max_workers
    #      # Scale based on time of day
    #      Time.now.hour < 8 ? 15 : 5
    #    end
    def max_workers
      Resque::Kubernetes.max_workers
    end
  end
end
