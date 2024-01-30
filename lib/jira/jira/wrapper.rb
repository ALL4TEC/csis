# frozen_string_literal: true

class Jira::Wrapper
  attr_accessor :client, :jira_config

  OPTIONS = {
    auth_type: :oauth,
    signature_method: 'RSA-SHA1',
    rest_base_path: '/rest/api/2',
    request_token_path: '/plugins/servlet/oauth/request-token',
    authorize_path: '/plugins/servlet/oauth/authorize',
    access_token_path: '/plugins/servlet/oauth/access-token',
    use_ssl: true,
    private_key_file: nil, # https://github.com/sumoheavy/jira-ruby/issues/287
    private_key: Rails.application.credentials.dig(:jira, :rsa_priv),
    consumer_key: Rails.application.credentials.dig(:jira, :consumer_key)
  }.freeze

  def initialize(jira_config)
    @jira_config = jira_config
    set_options
  end

  def set_options
    @client = JIRA::Client.new(OPTIONS.merge(options_h))
  end

  def request_token
    @client.request_token(oauth_callback: "#{ENV.fetch('ROOT_URL', nil)}/jira/oauth")
  end

  def set_request_token(request_token: @jira_config.login,
    request_secret: @jira_config.password)
    @client.set_request_token(request_token, request_secret)
  end

  def auth_token(oauth_verifier)
    @client.init_access_token(oauth_verifier: oauth_verifier)
  end

  def set_auth_token(auth_token: @jira_config.login, auth_secret: jira_config.password)
    @client.set_access_token(auth_token, auth_secret)
  end

  def server_reachable?
    @client.Project.all
    true
  rescue JIRA::HTTPError
    false
  end

  def project_exists?(project_id: @jira_config.project_id)
    @client.Project.find(project_id)
    true
  rescue JIRA::HTTPError
    false
  end

  # Options :
  # - description: issue's content
  # - weblink_url: link to an external related resource
  # - weblink_title: displayed name for the weblink
  def create_issue(title, description: '', weblink_url: '', weblink_title: '',
    project_id: @jira_config.project_id)
    issue = @client.Issue.build
    issue.save(issue_h(title, project_id, description))

    if !weblink_url.empty? && !weblink_title.empty?
      link = issue.remotelink.build
      link.save(link_h(weblink_url, weblink_title))
    end

    issue.key
  end

  def comment(issue_id, text)
    issue = @client.Issue.find(issue_id)
    issue.save(comment_h(text))
  end

  def close_issue(issue_id)
    issue = @client.Issue.find(issue_id)
    transition = issue.transitions.all.find { |t| t.to.statusCategory['key'] == 'done' }
    issue.transitions.build.save(transition_h(transition))
  end

  private

  def issue_h(title, project_id, description)
    {
      fields: {
        summary: title,
        project: { key: project_id },
        issuetype: { name: 'Task' }, # TODO: hardcoded issue type?
        description: description
      }
    }
  end

  def comment_h(text)
    {
      update: {
        comment: [{
          add: {
            body: text
          }
        }]
      }
    }
  end

  def link_h(weblink_url, weblink_title)
    { object: { url: weblink_url, title: weblink_title } }
  end

  def transition_h(transition)
    {
      transition: {
        id: transition.id
      }
    }
  end

  def options_h(url: @jira_config.url, context: @jira_config.context)
    { site: url, context_path: context }
  end
end
