# Shipyrd

Shipyrd is a deployment status dashboard for MRSK based deployments.

# Setup

There's two main parts to getting going with Shipyrd. The first part is getting Shipyrd
running as an accessory within your existing MRSK setup. The second is enabling the various
hooks that MRSK supports to update the deploy state in Shipyrd.

1. Add shipyrd as an accessory. Give it a subdomain with traefik and point your DNS to the same
host.

- SHIPYRD_API_KEY - Generate an API key(`bin/rails secret`) and set it in your env file as `SHIPYRD_API_KEY`,
this will be the password for basic HTTP authentication.
- SHIPYRD_DATABASE_URL - Point this to a postgresql:// address and new database so that Shipyrd can store deployments.

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

2. Setup the `shipyrd` gem in your Rails application.

- Add the `shipyrd` gem to your rails application
- Set `SHIPYRD_API_KEY` to the same API key you just configured within MRSK.
- Set `SHIPYRD_HOST` to the host you just set as a router with traefik.

.mrsk/hooks/pre-connect
``` ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'shipyrd'

Shipyrd.trigger('pre-connect')
```

.mrsk/hooks/pre-build
``` ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'shipyrd'

Shipyrd.trigger('pre-build')
```

.mrsk/hooks/pre-deploy
``` ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'shipyrd'

Shipyrd.trigger('pre-deploy')
```

.mrsk/hooks/post-deploy
``` ruby
#!/usr/bin/env ruby

require 'bundler/setup'
require 'shipyrd'

Shipyrd.trigger('post-deploy')
```

# TODOS


