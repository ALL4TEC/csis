# To increase allowed clock drift, specify value in seconds via 'SAML_CLOCK_DRIFT' env var
Rails.application.config.saml_clock_drift = ENV.fetch('SAML_CLOCK_DRIFT', 1.second)
Rails.application.config.saml_authn_requests_signed = true # (En/Dis)able signature on AuthNRequest
Rails.application.config.saml_logout_requests_signed = true # (En/Dis)able signature on Logout Request
Rails.application.config.saml_logout_responses_signed = true # (En/Dis)able signature on Logout Response
Rails.application.config.saml_want_assertions_signed = true # (En/Dis)able the requirement of signed assertion
Rails.application.config.saml_metadata_signed = true # (En/Dis)able signature on Metadata,
Rails.application.config.saml_digest_method = XMLSecurity::Document::SHA512
Rails.application.config.saml_signature_method = XMLSecurity::Document::RSA_SHA512
Rails.application.config.saml_embed_sign = false
Rails.application.config.saml_check_idp_cert_expiration = false
Rails.application.config.saml_check_sp_cert_expiration = false
Rails.application.config.saml_sp_certificate = ENV['SAML_SP_CERTIFICATE']
Rails.application.config.saml_sp_private_key = ENV['SAML_SP_PRIVATE_KEY']
