# frozen_string_literal: true

require 'kubeclient'

module Kubernetes
  # Spins up Kubernetes Jobs to run Resque workers.
  class KubeManager
    NAMESPACE = ENV.fetch('NAMESPACE', 'default')
    SERVICE_ACCOUNT = ENV.fetch('SERVICE_ACCOUNT', 'csis-sa')

    attr_reader :owner
    private :owner

    def initialize(owner)
      @owner             = owner
      @default_namespace = NAMESPACE
      @service_account = SERVICE_ACCOUNT
    end

    # Check manifest conformance function of kubernetes resource
    # Start a new job if possible
    # Needs a block to validate resource creation function of meta argument
    # @returns Kubeclient::Resource.new(manifest)
    def apply_kubernetes_resource
      manifest = Resque::Kubernetes::DeepHash.new.merge!(owner.manifest)
      ensure_namespace(manifest)
      ensure_service_account(manifest)

      # Do not start job if not wanted
      meta = manifest['metadata']
      yield meta

      adjust_manifest(manifest)

      Kubeclient::Resource.new(manifest)
    end

    protected

    def scans_client
      @scans_client ||= client('/apis/execution.securecodebox.io')
    end

    def jobs_client
      @jobs_client ||= client('/apis/batch')
    end

    def pods_client
      @pods_client ||= client('')
    end

    def client(scope)
      if (kubecli = Resque::Kubernetes.kubeclient).present?
        return Resque::Kubernetes::RetriableClient.new(kubecli)
      end

      client = build_client(scope)
      Resque::Kubernetes::RetriableClient.new(client) if client
    end

    def build_client(scope)
      context = Resque::Kubernetes::ContextFactory.context
      return unless context

      ctx_namespace = context.namespace
      @default_namespace = ctx_namespace if ctx_namespace

      Kubeclient::Client.new(context.endpoint + scope, context.version, **context.options)
    end

    def completed_pod
      ->(status) { status.state.terminated.reason == 'Completed' }
    end

    # @params pod
    # @returns status.phase == 'Succeeded' && check that all containerStatuses are completed
    def finished_pod(pod)
      status = pod.status
      status.phase == 'Succeeded' && status.containerStatuses.all?(&completed_pod)
    end
  end
end
