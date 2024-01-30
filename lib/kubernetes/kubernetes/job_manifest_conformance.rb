# frozen_string_literal: true

module Kubernetes
  # Provides functions to ensure a manifest conforms to a job specification
  # and includes details needed for resque-kubernetes jobs
  module JobManifestConformance
    include Kubernetes::CommonManifestConformance
    include Resque::Kubernetes::ManifestConformance
  end
end
