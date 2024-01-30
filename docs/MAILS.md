# Mails

## Smtp server configuration

- SMTP_ADDRESS: smtp server
- SMTP_PORT: defaults to 587
- MAIL_USER_NAME: no default value
- MAIL_PWD: no default value
- SMTP_DOMAIN: no default value
- SMTP_AUTHENTICATION: defaults to :login
- SMTP_ENABLE_STARTTLS_AUTO: defaults to true

## From emails configuration

- **ACTIONS_EMAIL:**

  Email used to send mails concerning remediation actions
  Needs to be specified in loaded gpg key to allow mails encryption
  
- **DEFAULT_FROM_EMAIL:**
  
  If not set, defaults to server MAIL_USER_NAME
  In order to be able to use this email, smtp server must allow MAIL_USER_NAME to send as DEFAULT_FROM_EMAIL

## GPG

- **GNUPGHOME** env var specifies where to import keys.
When updating a user.pub_key, pub_key is imported as a key validation

=> GNUPGHOME must be specified in app AND queue pods to be able to import keys AND use them to encrypt mails.
