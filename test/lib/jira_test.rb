# frozen_string_literal: true

require 'test_helper'
require 'jira'

class JiraTest < ActionDispatch::IntegrationTest
  test 'Jira::Wrapper set_request_token does not crash (bugfix)' do
    jira_config = JiraConfig.new(login: 'test', password: 'test')
    wrapper = Jira::Wrapper.new(jira_config)
    assert_nothing_raised { wrapper.set_request_token }
  end
end
