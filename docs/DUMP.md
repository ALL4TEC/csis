# How to create DEMO seed file

## Using CleverCloud backups

> Restore database

__Using pg_restore__

```bash
sudo docker cp ../../Downloads/postgresql_e8b26fda-d721-42a2-90d8-ba356786e321-20191106021200 csis_db_1:/tmp/backup

# Run multiple time (dunno why)
sudo docker exec csis_db_1 pg_restore -U postgres -d csis_dev --format=c /tmp/backup
```

__Using pg_admin__

```html
url: 127.0.0.1:8081
Right clic on target db
Restore...
Choose file
Restore
```

## Anonymize values

```html
/!\ DEFAULT SCOPE IS OFTEN KEPT, REMEMBER TO ANONYMIZE DISCARDED OBJECTS (EASY WAY: .destroy_all)
```

### Values to anonymize

> /!\ Comment readonly in model for internal_id

```yaml
  Contact:
    internal_id: nil
    full_name: Faker::Name.name
    email: Faker::Internet.email
    public_key: nil
    password_digest: nil || Faker::Internet.password(min_length: 8, max_length: 20, mix_case: true, special_characters: true)
    notification_email: nil
    ref_identifier: nil
```

```ruby
  Contact.all.each do |c|
    c.update!(
      internal_id: nil,
      full_name: Faker::Name.name,
      email: Faker::Internet.email,
      public_key: nil,
      password_digest: nil,
      notification_email: nil,
      ref_identifier: nil)
  end
```

> /!\ Comment readonly in model for internal_id

```yaml
  Client:
    internal_id: nil
    name: Faker::Company.name
    web_url: Faker::Internet.domain_name
```

```ruby
  Client.all.each do |c|
    c.update!(
      internal_id: nil,
      name: Faker::Company.name,
      web_url: Faker::Internet.domain_name)
  end
```

```yaml
  Project:
    name: Faker::App.name
    folder_name: nil
```

```ruby
  Project.all.each do |p|
    p.update!(
      name: Faker::App.name,
      folder_name: nil)
  end
```

```yaml
  Report:
    title: r.project.name + ' ' + Faker::Date.in_date_period.to_s
    introduction: Faker::Lorem.paragraph
    wa_introduction: Faker::Lorem.paragraph
    vm_introduction: Faker::Lorem.paragraph
    notes: Faker::Lorem.paragraph
```


```ruby
  Report.all.each do |r|
    r.update!(
      title: r.project.name + ' ' + Faker::Date.in_date_period.to_s,
      introduction: Faker::Lorem.paragraph,
      wa_introduction: Faker::Lorem.paragraph,
      vm_introduction: Faker::Lorem.paragraph,
      notes: Faker::Lorem.paragraph)
  end
```

```yaml
  Aggregate:
    scope: nil
    solution: Faker::Lorem.paragraph
    description: Faker::Lorem.paragraph
```

```ruby
  Aggregate.update_all(
      scope: nil,
      solution: Faker::Lorem.paragraph,
      description: Faker::Lorem.paragraph)
```

```yaml
  Action:
    name: Faker::Hacker.say_something_smart
    description: Faker::Lorem.paragraph
    pmt_name: nil
    pmt_reference: nil
```

```ruby
  Action.all.each do |a|
    a.update!(
      name: Faker::Hacker.say_something_smart,
      description: Faker::Lorem.paragraph,
      pmt_name: nil,
      pmt_reference: nil)
  end
```

```yaml
  Team:
    name: Faker::Team.name
```

```ruby
  Team.all.each do |t|
    t.update!(
      name: Faker::Team.name)
  end
```

```yaml
  QualysConfig:
    login: Faker::Internet.username
    password: Faker::Internet.password
    name: Faker::Company.name
```

```ruby
  QualysConfig.all.each do |q|
    q.update!(
      login: Faker::Internet.username,
      password: Faker::Internet.password,
      name: Faker::Company.name)
  end
```

```yaml
  ReportWaScan:
    web_app_url: nil
```

```ruby
  ReportWaScan.update_all(web_app_url: nil)
```

```yaml
  VmTarget:
    ip: IPAddr.new(Faker::Internet.ip_v4_address)
```

```ruby
  VmTarget.all.each do |v|
    v.update!(
      ip: IPAddr.new(Faker::Internet.ip_v4_address))
  end
```

```yaml
  VmOccurrence:
    result: nil
```

```ruby
  VmOccurrence.update_all(result: nil)
```

> /!\ Comment readonly in model for reference

```yaml
  VmScan:
    reference: Faker::Number.number(digits: 8)
    title: 'VM : ' + Faker::App.name
    user_login: nil
    target: IPAddr.new(Faker::Internet.ip_v4_address)
```

```ruby
  VmScan.all.each do |v|
    v.update!(
      reference: Faker::Number.number(digits: 8),
      title: 'VM : ' + Faker::App.name,
      user_login: nil,
      target: IPAddr.new(Faker::Internet.ip_v4_address))
  end
```

> /!\ Comment readonly in model for uri


```yaml
  WaOccurrence:
    result: nil
    param: nil
    content: nil
    payload: nil
    data: Faker::Lorem.paragraph
    uri: 'https://' + Faker::Internet.domain_name
```

```ruby
  WaOccurrence.all.each do |w|
    w.update!(
      result: nil,
      param: nil,
      content: nil,
      payload: nil,
      data: Faker::Lorem.paragraph,
      uri: 'https://' + Faker::Internet.domain_name)
  end
```

> /!\ Comment readonly in model for reference

```yaml
  WaScan:
    internal_id: Faker::Number.number(digits: 8)
    reference: Faker::Number.number(digits: 8)
    name: 'WAS : ' + Faker::Internet.domain_name
    web_app_id: nil
    web_app_name: Faker::App.name
    web_app_url: Faker::Internet.domain_name
    profile_id: nil
    profile_name: nil
    launched_by_username: nil
    landing_page: nil
```

```ruby
  WaScan.all.each do |w|
    w.update!(
      internal_id: Faker::Number.number(digits: 8),
      reference: Faker::Number.number(digits: 8),
      name: 'WAS : ' + Faker::Internet.domain_name,
      web_app_id: nil,
      web_app_name: Faker::App.name,
      web_app_url: Faker::Internet.domain_name,
      profile_id: nil,
      profile_name: nil,
      launched_by_username: nil)
  end

  WaScan.all.map(&:landing_page).map(&:detach)
```

```yaml
  QualysWaClient:
    qualys_name: Faker::Company.name
    qualys_id: Faker::Number.number(digits: 8)
```

```ruby
  QualysWaClient.all.each do |q|
    q.update!(
      qualys_name: Faker::Company.name,
      qualys_id: Faker::Number.number(digits: 8))
  end
```

```yaml
  QualysVmClient:
    qualys_name: Faker::Company.name
    qualys_id: Faker::Number.number(digits: 8)
```

```ruby
  QualysVmClient.all.each do |q|
    q.update!(
      qualys_name: Faker::Company.name,
      qualys_id: Faker::Number.number(digits: 8))
  end
```

```yaml
  CertificateLanguage:
    sync_link: nil
```

```ruby
  CertificateLanguage.update_all(sync_link: nil)
```

```yaml
  Comment:
    author: Faker::Name.name
    comment: Faker::Hacker.say_something_smart
```

```ruby
  Comment.all.each do |c|
    c.update!(
      author: Faker::Name.name,
      comment: Faker::Hacker.say_something_smart)
  end
```

## Dump data objects

__Using the homemade script__

> Creates db/seeds/Model.rb files

```bash
./db/seeds/dump.sh
```

__Dump model manually__

> /!\ ID IS NOT DUMP BY DEFAULT (╯°□ °）╯︵ ┻━┻

```bash
rails db:seed:dump EXCLUDE=created_at,updated_at MODELS=Model FILE=db/seeds/Model.rb
```

## Create seeds.rb file

__Using the homemade script__

```bash
./db/seeds/createSeed.sh
```

## Use seeds.rb file

> /!\ Comment contacts validation in report's model if seeding without modifying Report.rb and ReportContact.rb, and uncomment ReportContact in db/seeds/createSeed.sh

> /!\ Retirer 'login: nil' et 'password: nil' pour les QualysConfig du DUMP

```html
Add ', contact_ids: ["id1", "id2", ...]' for each report if you want to use the script without having to comment model each time. (Good idea for kubernetes)
```

```bash
cp db/seeds/seeds.rb db/seeds.rb
rails db:seed
```