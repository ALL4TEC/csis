# frozen_string_literal: true

require 'test_helper'

class KubeJobTest < ActiveSupport::TestCase
  test 'KubeJob constants are well initialized' do
    assert_not_nil KubeJob::REGISTRY
    assert_not_nil KubeJob::INSTANCE_NAME
    assert_not_nil KubeJob::VERSION
    assert_not_nil KubeJob::NAMESPACE
    assert_not_nil KubeJob::SERVICE_ACCOUNT
  rescue NameError
    assert_false true
  end
end
