# frozen_string_literal: true

require 'test_helper'
require 'sellsy'

module Sellsy
  module Test
    class Contact
      include Sellsy::CsisPart

      CUSTOM_FIELDS = %w[customfields customFields].freeze
      def initialize(data)
        @people_id = '19452981'

        CUSTOM_FIELDS.any? do |cf_key|
          @csis = data[cf_key] if data.key?(cf_key)
        end
      end
    end

    class Client < Sellsy::ClientCommon
      include Sellsy::CsisPart
    end

    class Supplier < Sellsy::ClientCommon
      include Sellsy::CsisPart
    end
  end
end

class SellsyCsisPartTest < ActiveSupport::TestCase
  VALID_HASH = {
    'code' => 'csis',
    'formatted_value' => 'oui'
  }.freeze
  INVALID_HASH = {
    'code' => 'csis',
    'formatted_value' => 'non'
  }.freeze

  DATA = {
    Client: {
      ok: {
        'relationType' => 'client',
        'customfields' => [VALID_HASH]
      },
      ko: {
        'relationType' => 'client',
        'customfields' => [INVALID_HASH]
      }
    },
    Supplier: {
      ok: {
        'relationType' => 'supplier',
        'customfields' => [VALID_HASH]
      },
      ko: {
        'relationType' => 'supplier',
        'customfields' => [INVALID_HASH]
      }
    },
    Contact: {
      ok: {
        'customFields' => {
          'nogroup' => {
            'list' => [VALID_HASH]
          }
        }
      },
      ko: {
        'customFields' => {
          'nogroup' => {
            'list' => [INVALID_HASH]
          }
        }
      }
    }
  }.freeze

  def check_csis(klass, result)
    stub = proc do |_a0, _a1, _a2|
      JSON.parse(File.read("test/fixtures/files/LibTestValues/Sellsy_Contact_#{result}.json"))
    end
    Sellsy::Request.stub(:do_singular, stub) do
      a = instance_eval("Sellsy::Test::#{klass}", __FILE__, __LINE__) # Rubocop
          .new(DATA[klass.to_sym][result])
      cf_key = klass.in?(%w[Client Supplier]) ? 'customfields' : 'customFields'
      assert_equal a.csis, DATA[klass.to_sym][result][cf_key]
      assert_equal a.csis?, result == :ok
    end
  end

  test 'Client class csis ok' do
    check_csis('Client', :ok)
  end

  test 'Client class csis ko' do
    check_csis('Client', :ko)
  end

  test 'Supplier class csis ok' do
    check_csis('Supplier', :ok)
  end

  test 'Supplier class csis ko' do
    check_csis('Supplier', :ko)
  end

  test 'Contact class csis ok' do
    check_csis('Contact', :ok)
  end

  test 'Contact class csis ko' do
    check_csis('Contact', :ko)
  end
end
