# Shipyrd

The simple deployment dashboard for Kamal based deployments.

# Setup

There's two main parts to getting started with Shipyrd. The first part is getting Shipyrd
running as an accessory within your existing Kamal setup. The second is enabling the various
hooks that Kamal supports to update the deploy state in Shipyrd.

1. Add shipyrd as an accessory host. Within your Kamal accessories deploy configuration you'll need to add a new accessory for Shipyrd. Swap out the host IP address as well as the traefik host rule in the example below. You'll also want to point DNS towards your traefik host rule unless you already have a wildcard record pointing to your host.

``` yml
accessories:
  shipyrd:
    image: nickhammond/shipyrd:latest
    host: 867.530.9
    env:
      secret:
        - SHIPYRD_API_KEY
        - SHIPYRD_DATABASE_URL
    labels:
      traefik.http.routers.myapp-shipyrd.rule: Host(`shipyrd.myapp.com`)
```

The accessory configuration includes two environment secrets:

- SHIPYRD_API_KEY - Generate an API key(`bin/rails secret`) and set it in your env file as `SHIPYRD_API_KEY`,
this will be the password for basic HTTP authentication.
- SHIPYRD_DATABASE_URL - Point this to a postgresql:// address and new database so that Shipyrd can store deployments.

2. Configure your hooks. Setup the `shipyrd` gem in your Rails application.

- Add the `shipyrd` gem to your rails application
- Set `SHIPYRD_API_KEY` to the same API key you just configured within Kamal.
- Set `SHIPYRD_HOST` to the host you just set as a router with traefik.

.kamal/hooks/pre-connect
``` ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'shipyrd'

Shipyrd.trigger('pre-connect')
```

.kamal/hooks/pre-build
``` ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'shipyrd'

Shipyrd.trigger('pre-build')
```

.kamal/hooks/pre-deploy
``` ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'shipyrd'

Shipyrd.trigger('pre-deploy')
```

.kamal/hooks/post-deploy
``` ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'shipyrd'

Shipyrd.trigger('post-deploy')
```
