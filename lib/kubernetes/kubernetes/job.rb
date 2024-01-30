# frozen_string_literal: true

module Kubernetes
  module Job
    include Kubernetes::JobCommon

    def self.included(base)
      base.before_enqueue :before_enqueue_kubernetes_job
    end

    # A before_enqueue hook that adds worker jobs to the cluster.
    def before_enqueue_kubernetes_job(*_args)
      return unless Resque::Kubernetes.enabled

      manager = Kubernetes::JobsManager.new(self)
      manager.clear_finished_jobs
      # Normally, here, once jobs are deleted, linked pods are automatically removed too
      manager.clear_finished_pods
      manager.apply_kubernetes_job
    end
  end
end
