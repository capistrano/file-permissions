# Capistrano::FilePermissions

File permissions handling for Capistrano v3.*

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano', '~> 3.0.0'
gem 'capistrano-file-permissions'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-file-permissions

## Usage

Require the module in your `Capfile`:

```ruby
require 'capistrano/file-permissions'
```

Set the (relative) paths to the files you want to be handled during deployment,
and optionally add a user to give access.

```ruby
set :file_permissions_paths, ["app/logs", "app/cache"]
set :file_permissions_users, ["www-data"]
```

### Acl

Add the acl task to the deployment flow

```ruby
before "deploy:updated", "deploy:set_permissions:acl"
```

Assume `app/logs` is a shared directory, and `app/cache` is part of the normal
release, this gem would execute the following:

```
[..] setfacl -Rn -m u:www-data:rwX -m u:<deploy-user>:rwX <path-to-app>/shared/app/logs <path-to-app>/<release>/app/cache
```

### Other tasks
* deploy:set_permissions:chmod
* deploy:set_permissions:chgrp
* deploy:set_permissions:chown
* 
### Configuration

The gem makes the following configuration variables available (shown with defaults)

```ruby
set :file_permissions_roles, :all
set :file_permissions_paths, []
set :file_permissions_users, []
set :file_permissions_groups, []
set :file_permissions_chmod_mode, "0777"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
