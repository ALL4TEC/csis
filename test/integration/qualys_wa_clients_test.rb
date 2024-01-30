# frozen_string_literal: true

require 'test_helper'

class QualysWaClientsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot new/create qualys wa client' do
    get new_qualys_config_qualys_wa_client_path(qualys_configs(:qc_one))
    check_not_authenticated
    new_client_name = 'new_name'
    new_client_id = 'fepzgfjezog'
    post qualys_config_qualys_wa_clients_path(qualys_configs(:qc_one)), params:
    {
      qualys_wa_client:
      {
        qualys_id: new_client_id,
        qualys_name: new_client_name,
        team_ids: []
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot edit/update qualys wa client' do
    get edit_qualys_wa_client_path(qualys_wa_clients(:qwc_one))
    check_not_authenticated
    new_client_name = 'new_name'
    new_client_id = 'fepzgfjezog'
    put qualys_wa_client_path(qualys_wa_clients(:qwc_one)), params:
    {
      qualys_wa_client:
      {
        qualys_id: new_client_id,
        qualys_name: new_client_name,
        team_ids: []
      }
    }
    check_not_authenticated
  end

  test 'unauthenticated cannot delete qualys wa client' do
    delete qualys_wa_client_path(qualys_wa_clients(:qwc_one))
    check_not_authenticated
  end

  test 'authenticated superadmin only can create qualys wa client from qualys config
       of type consultants only' do
    sign_in users(:superadmin)
    get new_qualys_config_qualys_wa_client_path(qualys_configs(:qc_express))
    assert_response(200)
    new_client_name = 'new_name'
    new_client_id = 'fepzgfjezog'
    assert_raises MethodNotAllowedError do
      post qualys_config_qualys_wa_clients_path(qualys_configs(:qc_express)), params:
      {
        qualys_wa_client:
        {
          qualys_id: new_client_id,
          qualys_name: new_client_name,
          team_ids: []
        }
      }
      assert_nil QualysWaClient.find_by(qualys_name: new_client_name)
    end
    # Client must not be present
    post qualys_config_qualys_wa_clients_path(qualys_configs(:qc_one)), params:
    {
      qualys_wa_client:
      {
        qualys_id: new_client_id,
        qualys_name: new_client_name,
        team_ids: []
      }
    }
    assert_not_nil QualysWaClient.find_by(qualys_name: new_client_name)
  end

  test 'authenticated superadmin only can update qualys wa client' do
    sign_in users(:superadmin)
    get edit_qualys_wa_client_path(qualys_wa_clients(:qwc_one))
    assert_response(200)
    new_client_name = 'new_name'
    new_client_id = 'fepzgfjezog'
    put qualys_wa_client_path(qualys_wa_clients(:qwc_one)), params:
    {
      qualys_wa_client:
      {
        qualys_id: new_client_id,
        qualys_name: new_client_name,
        team_ids: []
      }
    }
    assert_not_nil QualysWaClient.find_by(qualys_name: new_client_name)
  end

  test 'authenticated superadmin only can delete qualys wa client' do
    sign_in users(:superadmin)
    delete qualys_wa_client_path(qualys_wa_clients(:qwc_one))
    assert_raises ActiveRecord::RecordNotFound do
      QualysWaClient.find(qualys_wa_clients(:qwc_one).id)
    end
  end
end
