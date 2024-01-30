# Copyright 2024 ALL4TEC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# CSIS

Computing Security Information System

## Prerequisites

> ### Librairies

* `ruby` (Check .ruby-version for preferred version)
* `postgresql-client, postgresql-client-common, libpq-dev` (>= 9.2)
* `nodejs` (>= 6)
* `npm`

> ### Services

Main application depends on 4 services:

* a postgresql server as a database
* a worker node to handle background jobs
* a scheduler node to schedule periodic jobs
* a redis server used by worker node and app to handle cache

> If wanting to use docker containers.

* `docker` *Community Edition* (>= 17.12)
* `docker-compose` (>= 1.18)

## Documentation

To generate an HTML version of project documentation, run following command and look under docs directory:

```bash
rails rdoc
```

Then to access to web version of documentation, launch a python web server like following:

```bash
cd doc/rdoc
# If Python < 3.0
python -m SimpleHTTPServer
# If Python >= 3.0
python -m http.server
```

And then go to <http://localhost:8000/> in a browser.

Following is a list of following availables README:

* [SOFTWARE_TREE](docs/SOFTWARE_TREE.md)
* [AUTHENTICATION](docs/AUTHENTICATION.md)
* [CONTRIBUTING-FAQ](docs/CONTRIBUTING-FAQ.md)
* [BDD](docs/DATABASE.md)
* [MAILS](docs/MAILS.md)
* [MAINTENANCE](docs/MAINTENANCE.md)
* [QUALITY](docs/QUALITY.md)
* [SCB](docs/SECURE_CODE_BOX.md)
* [SEED](docs/SEED.md)
* [TASKS](docs/TASKS.md)

## Development

A __docker-compose.yml__ is provided to ease application deployment.This file orchestrates 2 containers creation:

* a `postgresql` container in version 9.2, exposed on port `5432`, watch env vars concerning Postresql configuration.
* a `redis` container in version 4.0, exposed on port `6379`.

It is possible not to use docker-compose by installing and configuring those services separately.

External services access keys are stored ciphered in `config/credentials.yml.enc`. This means that Rails needs a key to handle encryption/decryption of this file:

* Either stored in a file `config/master.key`,
* either in `RAILS_MASTER_KEY` env var.

Once previous key is available, we must ensure frontend dependencies are available too.
To install all frontend npm dependencies:

```bash
npm install
```

Once all dependencies installed, launch puma web server to start application:

```bash
# Start sidecar services
$ docker-compose up -d
# Reinitialize default RAILS_ENV(development) database
# Dump sql structure
# And generate an erd diagram
$ rails db:migrate:reset
# Optionally launch a dedicated webpack-dev-server in another terminal
$ ./bin/webpack-dev-server
# Ensure following mandatory env vars are specified and loaded in server session
# POSTGRES_PASSWORD
# NODE_OPTIONS=--openssl-legacy-provider
# RAILS_MASTER_KEY
# OTP_SECRET_ENCRYPTION_KEY
# Activate cache (https://guides.rubyonrails.org/caching_with_rails.html#configuration)
$ rails dev:cache
# Start puma server
$ rails s
```

Application should be accessible at following address: <http://localhost:3000/>

If using double authentication, check requirements
[AUTHENTICATION](docs/AUTHENTICATION.md)

## Used frameworks

* __Rails__ (Framework): <https://guides.rubyonrails.org/index.html>
* __discard__ (Soft-delete): <https://github.com/jhawthorn/discard>
* __kaminari__ (Pagination): <https://github.com/kaminari/kaminari>
* __simple_form__ (Forms management): <https://github.com/plataformatec/simple_form>
* __devise__ (Users management / Authentication): <https://github.com/plataformatec/devise>
* __draper__ (Decorators): <https://github.com/drapergem/draper>
* __paper_trail__ (Audit logs): <https://github.com/paper-trail-gem/paper_trail>
* __sentry-raven__ (Error reporting): <https://github.com/getsentry/raven-ruby>
* __prawn__ (PDF generation): <https://github.com/prawnpdf/prawn>
* __resque__ (Background jobs): <https://github.com/resque/resque>
* __ransack__ (ActiveRecord search filters): <https://github.com/activerecord-hackery/ransack>

## Tests

To launch tests, requirements are the same as for development environment.

There are two kinds of tests, rails ones and rspec ones.

First, sidecar containers are needed:

```bash
docker-compose up -d
# Reinit test database
rails db:migrate:reset RAILS_ENV=test
```

To launch minitest tests (COVERAGE env var is optional and only needed for coverage data):

```bash
COVERAGE=true rails t
```

To launch rspec tests:

```bash
bundle exec rspec
```

## Versioning & Changelog

CSIS version is defined in config/initializers/version.rb

> ### via shell

```bash
rails csis:version
```

Changelog is also available and kept up to date.

## Webpacker v5

Npm was prefered to yarn default packages manager. Thus a task has been added to check npm presence:

```bash
rails webpacker:check_npm
```

and launch its installation if needed:

```bash
rails webpacker:npm_install
```

To launch webpack server and watch for live assets modifications:

```bash
./bin/webpack-dev-server
```

## External tools used by the application

> ### Resque

Jobs are used in the app for imports, watch some configurations, generate reports and certificates and maintenance. It is also used to launch secure code box k8s scans.
To be able to launch a non k8s job, a *resque* queue with at least 1 worker is needed:

```bash
env QUEUE="*" bundle exec rails resque:work
```

> ### [SCB (Scanners)](docs/SECURE_CODE_BOX.md)

## Maintenance

PaperTrail::MaintenanceJob manages:

* versions partitions tables
* notifications cleaning
* jobs cleaning

Must be scheduled to be launched each month at least.

## Reporting to central platform

If needing to send reports to central platform, first generate a token from platform, then paste it in credentials file.

> ### Manually send report through shell

```bash
rails lman:upload_report_(now|later)
```

# Images

Each tiers logos and services are property of corresponding companies. This includes among others:

* Cyberwatch
* Excel
* Facebook
* Google
* Linkedin
* Pinterest
* Puma
* Qualys
* SellSy
* Slack
* Twitter
* Youtube
* ZaProxy
* Zoho
