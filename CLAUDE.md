# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This App Does

Shipyrd is a deployment dashboard for your team. It tracks deploy lifecycle events, manages deployment locks, integrates with GitHub, and dispatches notifications to Slack/Discord/etc.

## Commands

```bash
# Run full CI suite (lint, security, tests, system tests) — mirrors GitHub Actions
bin/ci

# Run all tests
bundle exec rails test

# Run a single test file
bundle exec rails test test/models/deploy_test.rb

# Run a specific test
bundle exec rails test test/models/deploy_test.rb:42

# Run system tests
bundle exec rails test:system

# Lint
bundle exec standardrb

# Security scan
bundle exec brakeman

# Watch mode (tests + linting)
bundle exec guard
```

## Architecture

**Stack:** Rails 8.1, MySQL (multi-database), Hotwire (Turbo + Stimulus), Bulma CSS, Propshaft, Solid Queue, Solid Cable.

**Multi-database setup:**
- `primary` — app data (`SHIPYRD_DATABASE_URL`)
- `queue` — Solid Queue jobs (`SHIPYRD_QUEUE_DATABASE_URL`)
- `cable` — ActionCable subscriptions (`SHIPYRD_CABLE_DATABASE_URL`)

Migrations live in `db/migrate/`, `db/queue_migrate/`, and `db/cable_migrate/` respectively.

**Core model hierarchy:**
- `Organization` → has many `User` (via `Membership`), `Application`
- `Application` → has many `Destination`, `Deploy`; holds the API token used by Kamal hooks
- `Destination` — a named deploy target (e.g. "production"); can be locked; has many `Server`, `Channel`, `Deploy`
- `Deploy` — one record per Kamal lifecycle event (`pre-deploy`, `pre-connect`, `pre-build`, `post-deploy`); validates lock state on create
- `Channel` — notification channel config; triggers `NotificationJob` via `Deploy#dispatch_notifications`

**Real-time updates:** Models use `broadcasts` / `broadcasts_refreshes` (Turbo Streams over ActionCable) to push live updates to connected clients without explicit controller code.

**Authentication — two paths:**
1. User sessions (password or GitHub OAuth)
2. Bearer token — either an `Application` token (for Kamal webhook deploys) or a `User` token (for API calls); resolved in `ApplicationController#authenticate`

**Frontend:** No JS bundler — uses importmap. Stimulus controllers live in `app/javascript/controllers/`. CSS is Bulma + custom properties in `app/assets/stylesheets/application.css`.

**Background jobs (Solid Queue):** `NotificationJob`, `AvatarImporterJob`, `CleanupOldDeploysJob`, `CreateStripeCustomerJob`. Mission Control UI at `/jobs` (admin only).

**Notifications:** `Channel` is a polymorphic model (`app/models/channel.rb`) whose `owner` points to the integration type (`Webhook`, `OauthToken`). `lib/slack.rb` contains the low-level Slack client.

**Billing:** Stripe integration; `Organization` tracks trial/subscription state. Incoming Stripe webhooks handled by `Incoming::StripeController`.

**Testing:** Minitest + FactoryBot. System tests use Selenium. No mocking of the database — tests hit the real DB.

## Workflow

After creating a PR or pushing changes to an existing PR, run `bin/ci` to catch failures before GitHub Actions runs. Fix any issues before moving on.

## GitHub App integration

The Shipyrd GitHub App (used for deployment tracking via `GithubAppClient` / `GithubDeployment`) is registered with exactly these permissions — do not suggest adding others:

- **Deployments:** Read & Write
- **Environments:** Read & Write
- **Metadata:** Read

We intentionally do **not** request **Contents** access. Shipyrd only creates deployments and statuses on behalf of the user's installation; it does not read repo contents, and adding Contents access would broaden the App's scope without benefit. When walking users through setup (README, docs, UI hints, support answers), list only the three permissions above.
