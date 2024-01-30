# frozen_string_literal: true

module Kubernetes
  # Provides functions to ensure a manifest conforms to a job specification
  module CommonManifestConformance
    METADATA = 'metadata'

    def ensure_namespace(manifest)
      manifest[METADATA]['namespace'] ||= @default_namespace
    end

    def ensure_service_account(manifest)
      manifest['spec']['serviceAccountName'] ||= @service_account
    end

    def update_job_name(manifest)
      manifest[METADATA]['name'] += "-#{Resque::Kubernetes::DNSSafeRandom.random_chars}"
    end
  end
end
