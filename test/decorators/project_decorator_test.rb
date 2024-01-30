# frozen_string_literal: true

require 'test_helper'

class ProjectDecoratorTest < Draper::TestCase
  test 'ProjectDecorator instanciation' do
    ProjectDecorator.new(Project.all)
  end
end
