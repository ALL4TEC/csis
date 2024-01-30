# FAQ

## How to avoid unauthenticated users to access controller pages ?

Use `before_action :authenticate_user!` like in following example to handle user redirection to connection page if not authenticated.

```ruby
class ExampleController < ApplicationController
  before_action :authenticate_user!

  # ...
end
```

## How to filter users per group ?

### Staff aka analysts group

```ruby
# Check if user is currently in staff group
current_user.staff?
```

### Contact aka remediation group

```ruby
# Check if user is currently in contact group
current_user.contact?
```

## How to use `SectionHeader` for pages visualization

To simplify and homogenize frontend display, a data struct grouping
all needed data to display page breadcrumbs, title and available menus.
To use it, just assign a SectionHeader instance to @app_section controller variable like inf the following example.

See Inuit::SectionHeader

```ruby
class ExampleController < ApplicationController
  def index
    @app_section = make_section_header(
      title: "Sample title",
      subtitle: "Sample subtitle",
      actions: [
        { label: "Action 1", href: root_path }
      ]
    )
  end
end
```

To ease actions and scopes list generation for each entity<->controller, see [HeadersConcern](../app/headers/README.md)
