# SECURE_CODE_BOX USAGE

## SECURITY

To provide a csis instance-dedicated securised webhook url, we must at least provide an env variable.
The content of this variable should be an uuid which can be generated with the following command:

```bash
SECURE_CODE_BOX_WH_UUID=$(bundle exec rake uuid:gen)
```

P.S.: A dedicated task has been added for uuid generation through cli.

## SCANNERS

Each available scan among following list:

- [x] zap
- [ ] nikto
- [ ] nmap
- [ ] amass
- [ ] kubehunter
- [ ] kube-audit
- [ ] trivy
- [ ] ncrack
- [ ] screenshooter
- [ ] ssh
- [ ] sslyze
- [ ] wpscan

must be specified in env var SCB_SCANNERS.

Ex:

```bash
SCB_SCANNERS='zaproxy, nikto, nmap'
```

## JOBS ENV VARS

- INSTANCE_NAME must be set to the instance name
- CONTAINER_IMAGE must be set to the wanted version, default to CSIS::VERSION
- NAMESPACE must be set to specify a namespace, default to 'default'
- SERVICE_ACCOUNT must be set to specify the serviceaccountname used to launch scans or jobs, default to 'csis-sa'
