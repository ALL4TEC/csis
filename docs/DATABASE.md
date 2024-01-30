# DATABASE

Postgresql is used as RDBMS

## Primary keys

[UUID version 4][uuid-v4]

See also `uuid-ossp` & `pgcrypto` extensions.

## Data encryption

Not yet available with Postgresql, which means database volumes must be encrypted.

## Audit logs

All modifications applied to stored entities are saved in an audit log where are specified:

* Entity type
* Modified entity primary key
* Change type (add/modify/remove)
* Change author
* Change diff

Used gem for that is [paper_trail].

[uuid-v4]: https://fr.wikipedia.org/wiki/Universal_Unique_Identifier
[paper_trail]: https://github.com/airblade/paper_trail#4a-finding-out-who-was-responsible-for-a-change
