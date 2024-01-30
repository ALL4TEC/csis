# frozen_string_literal: true

module Kubernetes
  # Spins up Kubernetes Jobs to run Resque workers.
  class JobsManager < Kubernetes::KubeManager
    include Kubernetes::JobManifestConformance

    JOBS_META = 'resque-kubernetes=job'
    PODS_META = 'resque-kubernetes=pod'
    QUEUE_META = "component=#{KubeJob::INSTANCE_NAME}-queue".freeze

    def clear_finished_jobs
      Rails.logger.info 'Deleting finished jobs'
      finished_jobs.each do |job|
        meta = job.metadata
        jobs_client.delete_job(meta.name, meta.namespace)
        Rails.logger.info "Deleted job/#{meta.name} in #{meta.namespace}"
      rescue Resque::Kubernetes::KubeException => e
        raise unless e.error_code == 404
      end
    end

    def clear_finished_pods
      Rails.logger.info 'Deleting finished pods'
      finished_pods.each do |pod|
        meta = pod.metadata
        pods_client.delete_pod(meta.name, meta.namespace)
        Rails.logger.info "Deleted pod/#{meta.name} in #{meta.namespace}"
      rescue Resque::Kubernetes::KubeException => e
        raise unless e.error_code == 404
      end
    end

    def apply_kubernetes_job
      job = apply_kubernetes_resource do |meta|
        return if running_queue_available?(meta['namespace'])
      end
      if job.present?
        Rails.logger.info 'Creating new job to instanciate queue pod'
        jobs_client.create_job(job)
      else
        Rails.logger.info 'Adding job to existing queue'
      end
    end

    private

    def finished_jobs
      resque_jobs = jobs_client.get_jobs(label_selector: JOBS_META,
        namespace: @default_namespace)
      resque_jobs.select { |job| job.spec.completions == job.status.succeeded }
    end

    def finished_pods
      resque_pods = pods_client.get_pods(label_selector: PODS_META,
        namespace: @default_namespace)
      finished_pods_l = ->(pod) { finished_pod(pod) }
      resque_pods.select(&finished_pods_l)
    end

    # Check if there is already a running queue
    # instanciated by a kube_job or scaled by admin
    # @param **namespace:** job metadata namespace
    def running_queue_available?(namespace)
      instanciated_queues = pods_client.get_pods(label_selector: QUEUE_META,
        namespace: namespace)
      finished_queues_l = ->(pod) { finished_pod(pod) }
      running = instanciated_queues.reject(&finished_queues_l)
      running.size.positive?
    end
  end
end
