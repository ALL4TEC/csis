# frozen_string_literal: true

require 'test_helper'

class AggregateDecoratorTest < Draper::TestCase
  test 'AggregateDecorator instanciation' do
    AggregateDecorator.new(Aggregate.all)
  end
end
