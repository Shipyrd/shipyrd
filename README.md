# Shipyrd

The simple deployment dashboard for Kamal-based deployments.

For a more detailed project and concept overview check out the [initial announcement details](https://www.fromthekeyboard.com/shipyrd-the-dashboard-for-your-kamal-deployments/).

<img src="doc/images/demo.png" border="1" />

## Setup

There's two main steps to getting started with Shipyrd.

1. Running Shipyrd as an accessory within your existing Kamal setup. 
2. Enable the various hooks that Kamal supports to update the deploy state in Shipyrd.

### Add shipyrd as an accessory

Within your Kamal accessories deploy configuration you'll need to add a new accessory for Shipyrd. Swap out the host IP address as well as the traefik host rule in the example below. You'll also want to point DNS towards this server unless you already have a wildcard record pointing to your host.

The accessory configuration requires a few secrets:

- `SHIPYRD_API_KEY` - Use `rails secret` or `openssl rand -hex 64` to generate one.
- `SHIPYRD_HOST` - Host where Shipyrd will live.
- `SHIPYRD_SECRET_KEY_BASE` - Use `rails secret` or `openssl rand -hex 64` to generate one.
- `SHIPYRD_ENCRYPTION_DETERMINISTIC_KEY` - Use `rails db:encryption:init` or `openssl rand -base64 32` to generate one.
- `SHIPYRD_ENCRYPTION_PRIMARY_KEY`- Use `rails db:encryption:init` or `openssl rand -base64 32` to generate one.
- `SHIPYRD_ENCRYPTION_KEY_DERIVATION_SALT` - Use `rails db:encryption:init` or `openssl rand -base64 32` to generate one.

``` yml
accessories:
  shipyrd:
    image: shipyrd/shipyrd:v0.3.5
    host: 867.530.9
    env:
      secret:
        - SHIPYRD_API_KEY
        - SHIPYRD_HOST
        - SHIPYRD_SECRET_KEY_BASE
        - SHIPYRD_ENCRYPTION_DETERMINISTIC_KEY
        - SHIPYRD_ENCRYPTION_PRIMARY_KEY
        - SHIPYRD_ENCRYPTION_KEY_DERIVATION_SALT
    labels:
      traefik.http.routers.YOURKAMALSERVICE-shipyrd.rule: Host(`shipyrd.myapp.com`)
    volumes:
      - shipyrd:/rails/db/production

```

*Make sure you update the traefik router in the configuration above to match the name of your service so that it's "#{service}-shipyrd"*

The `volumes` map is where the sqlite database will be stored which contains basic deploy information. For an overview of the information that's automatically collected with the Kamal hooks take a look at the documentation for the [shipyrd gem](https://github.com/shipyrd/shipyrd-gem).

With your accessory added and the `SHIPYRD_*` secrets set in your `.env` file for Kamal you should be able to push up your environment settings and then boot the Shipyrd accessory.

``` bash
kamal env push
kamal accessory boot shipyrd
```

*If you're upgrading you can reboot the Shipyrd accessory with `kamal accessory reboot shipyrd` so that it picks up the new version*

### Configure your Kamal hooks

Setup the `shipyrd` gem in your Rails application by adding `shipyrd` to your *Gemfile* and then configure the various hooks.

If you're already using any of these hooks just place the below code in the hook at the point of success within the hook. If you're creating new hooks for all of these make sure that you make them all executable with `chmod +x .kamal/hooks/pre-connect` for example.

*.kamal/hooks/pre-connect*
``` ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'shipyrd'

Shipyrd::Client.new.trigger('pre-connect')
```

*.kamal/hooks/pre-build*
``` ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'shipyrd'

Shipyrd::Client.new.trigger('pre-build')
```

*.kamal/hooks/pre-deploy*
``` ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'shipyrd'

Shipyrd::Client.new.trigger('pre-deploy')
```

*.kamal/hooks/post-deploy*
``` ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'shipyrd'

Shipyrd::Client.new.trigger('post-deploy')
```

### Deploy

With the triggers added to your Kamal hooks you'll now be able to see your app go through the deploy process in Shipyrd. Once a deploy completes you'll then be able to see the changes that went out with a deploy, who deployed it, when it was last deployed, how long the deploy took. 

### Customizing the deploy performer

Kamal sets `ENV['KAMAL_PERFORMER']` to your username on your computer via `git config user.email` or `whoami`, whichever it finds first. Shipyrd will instead fetch your GitHub username from your local configuration if it's set since this helps with linking over to GitHub and avatars. You can set your GitHub username in your local configuration via:

```
gh config get -h github.com [USERNAME]
```

## Upgrading

When you're ready to upgrade to a newer version of Shipyrd it's just a matter of bumping the version in your _deploy.yml_ file and then rebooting the accessory via Kamal.

1. Change the version(`v4.0.4`) in the image reference line in your _deploy.yml_ file.

```
image: shipyrd/shipyrd:v4.0.4
```

2. Reboot the accessory via Kamal.

```
kamal accessory reboot shipyrd
```

The reboot command retains your data and just stops the container, removes the container, starts the container with the new version. Rebooting will cause a short downtime while the new container boots up, usually just a few seconds.

## Contributing

If you discover an issue, or are interested in a new feature, please open an issue. If you want to contribute code, feel free to open a pull request. If the PR is substantial, it may be beneficial to open an issue beforehand to discuss.
