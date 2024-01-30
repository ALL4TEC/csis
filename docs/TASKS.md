# Tâches

## Qualys imports

> ### Vulnerabilities database

To import all vulnerabilities from Qualys knowledge base API:

```bash
rails qualys:vulnerabilities:import_all
```

If a first import has already been performed and only new vulnerabilities are needed, then prefer to call:

```bash
rails qualys:vulnerabilities:import_last
```

which import vulnerabilities more recent than the most recent one previously imported in CSIS.

> ### Scans

To import scans related to all active Qualys accounts:

```bash
rails qualys:scans:import
```

## Imports Sellsy

> ### Clients et Contacts

To import Sellsy account clients and contacts:

```bash
rails sellsy:import_(now|later)
```

## Génération des rapports

```bash
rails pdf:gen_scan_report_(now|later) [export_id, archi]
```

```bash
rails pdf:gen_pentest_report_(now|later) [export_id]
```

## Génération des certificats

```bash
rails pdf:gen_certificate_(now|later) [project, lang]
```

## Notifications

To remove all old (3 months old) users notifications:

```bash
rails notifications:clear_old
```

To remove all users notifications linked to a deleted paper_trail version:

```bash
rails notifications:clear_linked_to_nil_version
```

To perform 2 previous tasks:

```bash
rails notifications:clear_all
```

## Cyberwatch

> ### Test first account configuration (needs some improvements)

```bash
rails cyberwatch:test:auth
```

```bash
rails cyberwatch:test:ping
```

```bash
rails cyberwatch:test:assets
```

```bash
rails cyberwatch:test:vulnerabilities
```

```bash
rails cyberwatch:test:scans
```

## PMT

> ### Test that a configuration didn't expire

```bash
rails pmt:check_configs
```

## Maintenance & Production management

> ### Partitioning PaperTrail::Versions

```bash
rails partition:versions
```

> ### Reschedule stored jobs (useful when migrating instance)

```bash
rails schedule:stored_jobs
```

> ### Schedule maintenance job

```bash
rails schedule:maintenance
```

> ### Gpg

To check that a gpg key associated to email available at key_path can be imported:

```bash
rails gpg:check [email, key_path]
```

## Utils

> ### Generate uuid

```bash
rails uuid:gen
```
