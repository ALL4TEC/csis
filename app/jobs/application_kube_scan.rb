# frozen_string_literal: true

class ApplicationKubeScan < ApplicationJob
  include SecureCodeBox::Kubernetes::Scan

  INSTANCE_NAME = ENV.fetch('INSTANCE_NAME', 'undefined')
end
