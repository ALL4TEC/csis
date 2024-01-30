# frozen_string_literal: true

require 'test_helper'
require 'sellsy'

class SellsyTest < ActionDispatch::IntegrationTest
  test 'Sellsy::Contact can be instanciated' do
    c = Sellsy::Contact.new(YAML.safe_load_file(
      'test/fixtures/files/LibTestValues/Sellsy_Contact.txt',
      permitted_classes: [
        Sellsy::Contact,
        Phonelib::Phone,
        Symbol
      ]
    ).as_json)
    assert c.instance_of?(Sellsy::Contact)
  end

  test 'Sellsy::Client can be instanciated' do
    j = YAML.safe_load_file(
      'test/fixtures/files/LibTestValues/Sellsy_Client.txt',
      permitted_classes: [
        Sellsy::Client,
        Time,
        Phonelib::Phone,
        Symbol,
        URI::HTTPS,
        URI::RFC3986_Parser,
        Regexp
      ]
    ).as_json
    j['joindate'] = Time.now.in_time_zone.to_s # Histoire d'avoir une value qui fonctionne ...
    c = Sellsy::Client.new(j)
    assert c.instance_of?(Sellsy::Client)
  end

  test 'Sellsy::Supplier can be instanciated' do
    j = YAML.safe_load_file(
      'test/fixtures/files/LibTestValues/Sellsy_Supplier.txt',
      permitted_classes: [
        Sellsy::Supplier,
        Phonelib::Phone,
        Symbol,
        Time
      ]
    ).as_json
    j['joindate'] = Time.now.in_time_zone.to_s # Histoire d'avoir une value qui fonctionne ...
    supplier = Sellsy::Supplier.new(j)
    assert supplier.instance_of?(Sellsy::Supplier)
  end
end
