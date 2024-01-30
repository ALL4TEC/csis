# frozen_string_literal: true

require 'test_helper'

class ReportDecoratorTest < Draper::TestCase
  test 'ReportDecorator instanciation' do
    ReportDecorator.new(Report.all)
  end
end
