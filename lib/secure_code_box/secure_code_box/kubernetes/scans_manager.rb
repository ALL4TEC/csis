# frozen_string_literal: true

module SecureCodeBox
  module Kubernetes
    # Spins up Kubernetes Scans to run Resque workers.
    class ScansManager < ::Kubernetes::KubeManager
      include SecureCodeBox::Kubernetes::ScanManifestConformance

      JOBS_META = 'securecodebox-kubernetes=job'

      def delete_finished_scans_jobs_and_associated_pods
        Rails.logger.info 'Delete finished scans jobs and pods'
        finished_scans_jobs.each do |job|
          delete_finished_job(job.metadata)
        rescue Resque::Kubernetes::KubeException => e
          raise unless e.error_code == 404
        end
      end

      def apply_kubernetes_scan
        Rails.logger.info 'Creating new scan'
        scan = apply_kubernetes_resource do |meta|
          return if scans_maxed?(meta['namespace'])
        end
        scan_creation_response = nil
        if scan.present?
          scan_creation_response = scans_client.create_scan(scan)
          Rails.logger.info "Scan creation response: #{scan_creation_response}"
        else
          Rails.logger.info 'Too many scans running !'
        end
        manage_csis_data(scan_creation_response)
      end

      private

      def finished_scans_jobs
        securecodebox_jobs = jobs_client.get_jobs(label_selector: JOBS_META,
          namespace: @default_namespace)
        securecodebox_jobs.select { |job| job.spec.completions == job.status.succeeded }
      end

      def finished_scan_pods(job_name)
        securecodebox_pods = pods_client.get_pods(label_selector: "job-name=#{job_name}",
          namespace: @default_namespace)
        finished_pods = ->(pod) { finished_pod(pod) }
        securecodebox_pods.select(&finished_pods)
      end

      def delete_finished_job(job_meta)
        jobs_client.delete_job(job_meta.name, job_meta.namespace)
        # Pour chaque job on va chercher le pod correspondant
        finished_scan_pods(job_meta.name).each do |pod|
          delete_finished_pod(pod.metadata)
        end
      end

      def delete_finished_pod(pod_meta)
        pods_client.delete_pod(pod_meta.name, pod_meta.namespace)
      end

      def manage_csis_data(scan_creation_response)
        scan_launch = owner.scan_launch
        # Create job object and link it to scan_launch to be able to update status
        # once terminated
        job_h = {
          resque_job_id: owner.job_id,
          clazz: owner.class,
          progress_step: 0,
          progress_steps: 1,
          creator: scan_launch.launcher,
          subscribers: scan_launch.report.project.staffs
        }
        if scan_creation_response.present?
          job_h[:status] = :init
          scan_launch_h = {
            status: :launched,
            kube_scan_id: scan_creation_response['metadata']['uid']
          }
        else
          job_h[:status] = :error
          job_h[:stacktrace] = 'Too many scans running !'
          scan_launch_h = {
            status: :errored
          }
        end
        job = Job.create!(job_h)
        scan_launch_h[:launched_at] = Time.zone.now
        scan_launch_h[:csis_job_id] = job.id
        scan_launch.update!(scan_launch_h)
      end

      # Check if there are more than Resque::Kubernetes.max_workers running scans
      # @param **namespace:** job metadata namespace
      def scans_maxed?(namespace)
        securecodebox_jobs = jobs_client.get_jobs(label_selector: JOBS_META,
          namespace: namespace)
        running = securecodebox_jobs.reject { |job| job.spec.completions == job.status.succeeded }
        running.size >= owner.max_workers
      end
    end
  end
end
