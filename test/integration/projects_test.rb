# frozen_string_literal: true

require 'test_helper'

class ProjectsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'unauthenticated cannot list projects' do
    get projects_path
    check_not_authenticated
  end

  test 'unauthenticated cannot list trashed projects' do
    get trashed_projects_path
    check_not_authenticated
  end

  test 'unauthenticated cannot consult project' do
    project = Project.first
    get "/projects/#{project.id}"
    check_not_authenticated
  end

  test 'unauthenticated cannot know if a project exists' do
    get '/projects/ABC'
    check_not_authenticated
  end

  test 'authenticated staff can list projects' do
    sign_in users(:staffuser)
    get projects_path
    assert_select 'main table.table' do
      Project.page(1).each do |project|
        assert_select 'td', text: project.name
      end
    end
  end

  test 'authenticated staff can list trashed projects' do
    sign_in users(:staffuser)
    get trashed_projects_path
    assert_select 'main table.table' do
      Project.trashed.page(1).each do |project|
        assert_select 'td', text: project.name
        assert_select 'td', text: project.client.name
      end
    end
  end

  test 'authenticated staff can filter projects by name containing' do
    sign_in users(:staffuser)
    get projects_path, params: { q: { name_cont: 'ville' } }
    assert_select 'main table.table' do
      assert_select 'td', text: 'Hospiville'
      assert_select 'td', text: 'MaPUI', count: 0
    end
  end

  test 'authenticated staff can filter projects by client name containing' do
    sign_in users(:staffuser)
    get projects_path, params: { q: { client_name_cont: 'ville' } }
    assert_select 'main table.table' do
      assert_select 'td', text: 'Hospiville', count: 0
      assert_select 'td', text: 'MaPUI', count: 0
    end
  end

  test 'authenticated staff can filter projects by name containing in trashed' do
    sign_in users(:staffuser)
    get trashed_projects_path, params: { q: { name_cont: 'ville' } }
    assert_select 'main table.table' do
      assert_select 'td', text: 'Hospiville', count: 0
      assert_select 'td', text: 'MaPUI', count: 0
    end
  end

  test 'authenticated staff can filter projects by client name containing in trashed' do
    sign_in users(:staffuser)
    get trashed_projects_path, params: { q: { client_name_cont: 'ville' } }
    assert_select 'main table.table' do
      assert_select 'td', text: 'Hospiville', count: 0
      assert_select 'td', text: 'MaPUI', count: 0
    end
  end

  test 'authenticated staff can view project' do
    sign_in users(:staffuser)
    p = Project.first
    get "/projects/#{p.id}"
    assert_select 'h4', text: p.name
  end

  test 'authenticated staff cannot consult inexistant project' do
    sign_in users(:staffuser)
    get '/projects/ABC'
    assert_redirected_to projects_path
  end

  test 'unauthenticated staff cannot update project' do
    p = Project.first
    put "/projects/#{p.id}", params:
      {
        project:
        {
          name: 'test'
        }
      }
    check_not_authenticated
  end

  test 'authenticated staff can update project' do
    sign_in users(:staffuser)
    p = Project.first
    put "/projects/#{p.id}", params:
      {
        project:
        {
          name: 'test'
        }
      }
    updated_p = Project.find_by(id: p.id)
    assert_equal 'test', updated_p.name
  end

  test 'authenticated staff can update project report_auto_generation_cron' do
    sign_in users(:staffuser)
    p = Project.first
    name = 'test'
    cron = '1 2 1 2 1'
    put "/projects/#{p.id}", params:
      {
        project:
        {
          name: name,
          auto_generate: true,
          scan_regex: 'something',
          report_auto_generation_cron: cron
        }
      }
    updated_p = Project.find_by(id: p.id)
    assert_equal name, updated_p.name
    assert_equal cron, updated_p.report_auto_generation_cron.value
  end

  test 'authenticated staff cannot update non-existent project' do
    sign_in users(:staffuser)
    put '/projects/ABC', params:
    {
      project:
      {
        name: 'test'
      }
    }
    assert_redirected_to projects_path
  end

  test 'unauthenticated staff cannot consult non-existent project form' do
    get '/projects/ABC/edit'
    check_not_authenticated
  end

  test 'authenticated staff cannot consult non-existent project form' do
    sign_in users(:staffuser)
    get '/projects/ABC/edit'
    assert_redirected_to projects_path
  end

  test 'unauthenticated staff cannot create new project' do
    get '/projects/new'
    check_not_authenticated
  end

  test 'authenticated staff can create new project' do
    sign_in users(:staffuser)
    c = Client.first
    s = Client.last
    t = Team.first
    post '/projects', params:
      {
        project:
        {
          name: 'test',
          team_ids: [t.id],
          client_id: c.id,
          supplier_ids: [s.id]
        }
      }
    updated_p = Project.find_by(name: 'test')
    assert_equal c.id, updated_p.client_id
  end

  test 'authenticated staff can create new project with report_auto_generation_cron' do
    sign_in users(:staffuser)
    name = 'test'
    cron = '1 1 1 1 1'
    c = Client.first
    s = Client.last
    t = Team.first
    post '/projects', params:
      {
        project:
        {
          name: name,
          team_ids: [t.id],
          client_id: c.id,
          supplier_ids: [s.id],
          auto_generate: true,
          scan_regex: 'somename',
          report_auto_generation_cron: cron
        }
      }
    created_p = Project.find_by(name: name)
    assert_equal c.id, created_p.client_id
    assert_equal cron, created_p.report_auto_generation_cron.value
  end

  test 'authenticated staff cannot create new project without name' do
    sign_in users(:staffuser)
    c = Client.first
    s = Client.last
    t = Team.first
    post '/projects', params:
      {
        project:
        {
          team_ids: [t.id],
          client_id: c.id,
          supplier_ids: [s.id]
        }
      }
    assert_response(200)
  end

  test 'authenticated staff cannot create new project without client' do
    sign_in users(:staffuser)
    s = Client.last
    t = Team.first
    post '/projects', params:
      {
        project:
        {
          name: 'test',
          team_ids: [t.id],
          supplier_ids: [s.id]
        }
      }
    assert_response(200)
  end

  test 'authenticated staff cannot create new project without teams' do
    sign_in users(:staffuser)
    c = Client.first
    s = Client.last
    post '/projects', params:
      {
        project:
        {
          name: 'test',
          client_id: c.id,
          supplier_ids: [s.id]
        }
      }
    assert_response(200)
  end

  test 'unauthenticated staff cannot delete project' do
    p = Project.first
    delete "/projects/#{p.id}"
    check_not_authenticated
  end

  test 'unauthenticated staff cannot know if a project exists trying to delete it' do
    delete '/projects/ABC'
    check_not_authenticated
  end

  test 'authenticated staff cannot delete non-existent project' do
    sign_in users(:staffuser)
    delete '/projects/ABC'
    assert_redirected_to projects_path
  end

  test 'authenticated staff can delete existent project' do
    p = Project.first
    sign_in users(:staffuser)
    delete "/projects/#{p.id}"
    assert_raises ActiveRecord::RecordNotFound do
      p = Project.find(p.id)
    end
  end

  test 'unauthenticated saff cannot know if a project exists trying to restore it' do
    put '/projects/ABC/restore'
    check_not_authenticated
  end

  test 'unauthenticated staff cannot restore a deleted project' do
    p = Project.first
    sign_in users(:staffuser)
    delete "/projects/#{p.id}"
    sign_out users(:staffuser)
    put "/projects/#{p.id}/restore"
    check_not_authenticated
  end

  test 'authenticated staff can restore a deleted project' do
    p = Project.first
    sign_in users(:staffuser)
    delete "/projects/#{p.id}"
    put "/projects/#{p.id}/restore"
    resurec_p = Project.find(p.id)
    assert_equal resurec_p.id, p.id
  end

  test 'authenticated staff cannot restore non-existent project' do
    sign_in users(:staffuser)
    put '/projects/ABC/restore'
    assert_redirected_to projects_path
  end

  test 'authenticated staff cannot restore non-deleted project' do
    p = Project.first
    sign_in users(:staffuser)
    put "/projects/#{p.id}/restore"
    assert_redirected_to projects_path
  end

  test 'authenticated staff can consult new project form' do
    sign_in users(:staffuser)
    get new_project_path
    assert_response :success
  end

  test 'authenticated staff can consult existent project form' do
    sign_in users(:staffuser)
    p = Project.first
    get edit_project_path(p)
    assert_response :success
  end

  test 'authenticated staff cannot update project without name' do
    sign_in users(:staffuser)
    put project_path(Project.first), params:
    {
      project:
      {
        name: nil
      }
    }
    assert_response 200
  end

  test 'authenticated staff cannot update project without client' do
    sign_in users(:staffuser)
    put project_path(Project.first), params:
    {
      project:
      {
        client_id: nil
      }
    }
    assert_response 200
  end
end
