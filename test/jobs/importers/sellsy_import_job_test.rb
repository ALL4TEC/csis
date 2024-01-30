# frozen_string_literal: true

require 'test_helper'

class Importers::SellsyImportJobTest < ActiveJob::TestCase
  NAME = 'name'

  test 'Clients, suppliers and contacts are correctly imported' do
    prev = Client.count
    previous = User.contacts.count

    launch_test_with_stub do
      asserts('Client')
      asserts('Supplier')

      Importers::SellsyImportJob.perform_now(nil, nil)
      assert_equal 5, Client.count - prev
      assert_not_equal previous, User.contacts.count
    end
  end

  test 'Clients, suppliers and contacts are checked for modif on import' do
    User.contacts.destroy_all
    Client.destroy_all

    launch_test_with_stub do
      Importers::SellsyImportJob.perform_now(nil, nil)

      contact_count = User.contacts.count
      clients_count = Client.clients.count
      suppliers_count = Client.suppliers.count

      # Clean first element
      User.contacts.first.destroy
      assert_equal contact_count - 1, User.contacts.count

      # Get first element of each kind
      modified_contact = User.contacts.first

      # Update name of each
      modified_contact.update(full_name: NAME)

      Importers::SellsyImportJob.perform_now(nil, nil)

      # Check one new element created corresponding to deleted resource
      assert_equal contact_count, User.contacts.count
      # And others were not duplicated
      assert_equal clients_count, Client.clients.count
      assert_equal suppliers_count, Client.suppliers.count

      # Check modified user name value are overriden by import
      assert_not_equal NAME, User.contacts.find_by(id: modified_contact.id).full_name
    end
  end

  private

  def launch_test_with_stub
    stub = stub_it

    Sellsy::Request.stub(:do_list, stub) do
      Sellsy::Contact.any_instance.stubs(:csis?).returns(true)
      yield
    end
  end

  def stub_it
    proc do |_a0, a1, a2|
      if a2[:pagination][:pagenum] == 1
        YAML.safe_load_file("test/fixtures/files/JobTestValues/#{a1}.txt", permitted_classes: [
                                                                             Sellsy::ListResponse,
                                                                             Sellsy::Client,
                                                                             Time,
                                                                             Sellsy::Contact,
                                                                             Phonelib::Phone,
                                                                             Symbol,
                                                                             URI::HTTPS,
                                                                             URI::RFC3986_Parser,
                                                                             Regexp,
                                                                             URI::HTTP,
                                                                             Sellsy::Supplier
                                                                           ],
          permitted_symbols: [],
          aliases: true) # Authorize aliases
      else
        Sellsy::ListResponse.new(a1,
          'infos' => { 'nbperpage' => 50, 'nbpages' => 1, 'pagenum' => 1, 'nbtotal' => 3 },
          'result' => {})
      end
    end
  end

  def asserts(entity)
    assert_equal Sellsy::Request.do_list(nil, "#{entity}.getList",
      pagination: { nbperpage: 50, pagenum: 1 }).class,
      Sellsy::ListResponse
    assert_equal Sellsy::Request.do_list(nil, "#{entity}.getList",
      pagination: { nbperpage: 50, pagenum: 5 }).class,
      Sellsy::ListResponse
  end
end
