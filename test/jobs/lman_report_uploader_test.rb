# frozen_string_literal: true

require 'test_helper'
require 'utils/tmp_file_helper'

class ResponseOk
  def status
    200
  end
end

class ResponseKo
  def status
    401
  end

  def headers
    'Accept: */*'
  end

  def body
    'Unauthorized'
  end
end

class LmanReportUploaderJobTest < ActiveJob::TestCase
  # Testing uploader ok
  test 'Ok response' do
    Faraday.stub(:post, ResponseOk.new) do
      response = LmanReportUploaderJob.perform_now
      assert_equal(response.status, 200)
    end
  end

  test 'Ko response' do
    Faraday.stub(:post, ResponseKo.new) do
      response = LmanReportUploaderJob.perform_now
      assert_equal(response.status, 401)
    end
  end
end
