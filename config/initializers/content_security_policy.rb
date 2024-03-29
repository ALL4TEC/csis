# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.style_src   :self, :https

  # Specify URI for violation reports
  # sentry_report_uri = Rails.application.credentials.dig(:sentry, :csp_report_uri)
  # policy.report_uri(sentry_report_uri) unless sentry_report_uri.nil?

  if Rails.env.development?
    policy.connect_src :self, :https, 'http://localhost:3035', 'ws://localhost:3035'
    policy.script_src :self, :https, :unsafe_eval
  else
    policy.script_src  :self, :https
  end
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = -> request {
  SecureRandom.base64(16)
}
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
