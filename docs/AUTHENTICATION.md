# Authentication

Application uses a uniq authentication system called [devise] for all users.
It allows login/password, Google OAuth or Microsoft Azure OAuth and SAML.

Google or Azure OAuth accounts credentials must be specified in app credentials and those must be configured on their part.

## 2FA

Double authentication can be forced per group/role/team/user and activated/deactivated for each user.
Only requirement is to have set following env var with a rails secret.

**OTP_SECRET_ENCRYPTION_KEY**

On peut générer une clef via la commande suivante:

```bash
bundle exec rake secret
```

Voir la gem [devise].

[devise]: https://github.com/plataformatec/devise

## SAML

**Certificate keys:**

To generate a Service Provider (SP) Certificate:

```bash
openssl genrsa -out saml.pem 2048
```

To generate private key:

```bash
openssl req -new -key saml.pem -out saml.csr
openssl x509 -req -days 365 -in saml.csr -signkey saml.pem -out saml.crt
```

Then SAML_SP_CERTIFICATE must point to certificate content (.crt)
and SAML_SP_PRIVATE_KEY to private key (.pem)

Beware it is not yet implemented in helm chart. Following is only a possible sample which should work but not tested.

```yaml
env:
  - name: SAML_SP_CERTIFICATE
    valueFrom:
      secretKeyRef:
        key: tls.crt
        name: csis-<instance>-tls
  - name: SAML_SP_PRIVATE_KEY
    valueFrom:
      secretKeyRef:
        key: tls.key
        name: csis-<instance>-tls
```
