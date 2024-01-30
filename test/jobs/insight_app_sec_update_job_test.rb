# frozen_string_literal: true

require 'test_helper'

class InsightAppSecUpdateJobTest < ActiveJob::TestCase
  test 'simple instanciation' do
    InsightAppSecUpdateJob.perform_now(nil, nil)
  end
end
