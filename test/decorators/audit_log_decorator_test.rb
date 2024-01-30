# frozen_string_literal: true

require 'test_helper'

class AuditLogDecoratorTest < Draper::TestCase
  test 'AuditLogDecorator instanciation' do
    AuditLogDecorator.new(PaperTrail::Version.all)
  end
end
