# frozen_string_literal: true

require 'test_helper'

class InsightAppSecImportJobTest < ActiveJob::TestCase
  test 'simple instanciation' do
    InsightAppSecImportJob.perform_now(nil, nil)
  end
end
