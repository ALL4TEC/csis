# frozen_string_literal: true

module SecureCodeBox
  module Kubernetes
    module Scan
      include ::Kubernetes::JobCommon

      def self.included(base)
        base.before_enqueue :before_enqueue_kubernetes_scan
      end

      # A before_enqueue hook that adds worker jobs to the cluster.
      def before_enqueue_kubernetes_scan(*_args)
        return unless Resque::Kubernetes.enabled

        init_args
        manager = ScansManager.new(self)
        manager.delete_finished_scans_jobs_and_associated_pods
        manager.apply_kubernetes_scan
      end

      # Child callback to set some manifest dynamic values
      def init_args; end
    end
  end
end
