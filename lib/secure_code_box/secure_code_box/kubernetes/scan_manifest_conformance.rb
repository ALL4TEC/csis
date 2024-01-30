# frozen_string_literal: true

# require 'common/kubernetes/common_manifest_conformance'

module SecureCodeBox
  module Kubernetes
    # Provides functions to ensure a manifest conforms to a job specification
    # and includes details needed for securecodebox-kubernetes
    module ScanManifestConformance
      include ::Kubernetes::CommonManifestConformance

      SCB_K8S_GROUP = 'securecodebox-kubernetes-group'

      private

      def adjust_manifest(manifest)
        add_labels(manifest)
        update_job_name(manifest)
      end

      def add_labels(manifest)
        manifest.deep_add(%w[metadata labels securecodebox-kubernetes], 'job')
        meta = manifest[METADATA]
        meta['labels'][SCB_K8S_GROUP] = meta['name']
      end
    end
  end
end
