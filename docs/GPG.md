# GPG

GNUPGHOME env var specifies where to import keys.
When updating a user.pub_key, pub_key is imported as a key validation
=> We must provide a GNUPGHOME dir in app pod AND we must use a volume to save data and be able to restore it.