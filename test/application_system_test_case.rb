# frozen_string_literal: true

require 'test_helper'
require 'webdrivers/chromedriver'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  def remove_uploaded_files
    FileUtils.rm_rf(Rails.root.join('storage_test'))
  end

  def after_teardown
    super
    remove_uploaded_files
  end
end
