# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.1
FROM ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_PATH="/usr/local/bundle"


# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git default-libmysqlclient-dev

# Install application gems
COPY Gemfile Gemfile.lock .ruby-version ./

RUN --mount=type=cache,id=gem-cache-3.3,sharing=locked,target=/srv/vendor \
    find /srv/vendor -type d -wholename 'ruby/3.3.0' -delete && \
    bundle config set app_config .bundle && \
    bundle config set path /srv/vendor && \
    bundle config set deployment 'true' && \
    bundle config set without 'development test toolbox' && \
    bundle install --jobs 8 && \
    bundle clean && \
    mkdir -p vendor && \
    bundle config set --local path vendor && \
    cp -ar /srv/vendor . && \
    rm -rf vendor/ruby/*/cache vendor/ruby/*/bundler/gems/*/.git && \
    find vendor/ruby/*/gems/ -name "*.c" -delete && \
    find vendor/ruby/*/gems/ -name "*.o" -delete

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN --mount=type=cache,id=bld-assets-cache,sharing=locked,target=tmp/cache/assets \
    SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile --trace

# Final stage for app image
FROM base

ARG SOLID_QUEUE_IN_PUMA=1
ENV SOLID_QUEUE_IN_PUMA=$SOLID_QUEUE_IN_PUMA

ARG COMMUNITY_EDITION=1
ENV COMMUNITY_EDITION=$COMMUNITY_EDITION

# Install packages needed for deployment
RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y curl default-mysql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    mkdir db/production && \
    chown -R rails:rails db log storage tmp db/production

RUN mkdir /shipyrd && chown rails:rails /shipyrd
VOLUME /shipyrd

USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
