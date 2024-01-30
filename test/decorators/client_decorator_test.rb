# frozen_string_literal: true

require 'test_helper'

class ClientDecoratorTest < Draper::TestCase
  test 'ClientDecorator instanciation' do
    ClientDecorator.new(Client.all)
  end
end
