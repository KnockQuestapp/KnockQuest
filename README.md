# KnockQuest

KnockQuest is the source-controlled Flutter application maintained and delivered exclusively from GitHub.

## Tech Stack

- Flutter stable (local SDK: 3.47.4)
- Dart 3.13.3 with the local SDK
- Targets: Android, iOS, Web, Windows, Linux, macOS

## Quick Start

On this development machine, use the project-local Flutter SDK at
`.toolchains/flutter`. Its SDK, Pub cache, Gradle cache, and Windows test data
stay under `D:\dev\KnockQuest` and are excluded from Git.

```powershell
.\scripts\local_flutter.ps1 check
.\scripts\local_flutter.ps1 web
```

For Windows desktop testing, first enable Windows Developer Mode so Flutter can
create plugin symlinks, then run `.\scripts\local_flutter.ps1 windows`. The
Android debug APK can be built with `.\scripts\local_flutter.ps1 android`; its
Android SDK and JDK also live under `.toolchains` on D:.

The app supports local testing accounts and Supabase Google sign-in. Register a
local account on the login screen, then sign in with those credentials. Use test
credentials only; the local account store is not a production authentication
system. Password reset email and billing still require service configuration.

## Google sign-in setup

1. In Supabase, open the KnockQuest project. Under **Project Settings → API Keys**,
   copy the project URL and **publishable** key. Do not use a service role or secret key.
2. Under **Authentication → URL Configuration**, set the Site URL to the web
   address used for testing and add the web address and
   `io.knockquest.app://login-callback/` to the redirect allow list. The local
   browser preview currently uses `http://127.0.0.1:8769`; use the actual port
   if you start the preview elsewhere.
3. In Google Cloud, create a Web OAuth client. Add the testing web origin under
   authorized JavaScript origins and the Supabase callback
   `https://<project-ref>.supabase.co/auth/v1/callback` under authorized redirect
   URIs. Configure the consent screen and add test users if the app is in test mode.
4. In Supabase **Authentication → Sign In / Providers → Google**, enable Google
   and enter the Google client ID and secret. Keep the secret in Supabase only.
5. Launch with the public app values as Dart defines:

   ```powershell
   .\.toolchains\flutter\bin\flutter.bat run -d chrome --web-port 8769 --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
   ```

   For an Android test build, use
   `.\scripts\local_flutter.ps1 android -SupabaseUrl https://<project-ref>.supabase.co -SupabasePublishableKey <publishable-key>`.
   The Android manifest includes the app callback link.
   The `.env.example` file documents variables but is not automatically loaded
   by Flutter.

## BoldTrail via Zapier

1. In Zapier, create a Zap with **Webhooks by Zapier → Catch Hook** as the trigger.
   Copy the generated Catch Hook URL. This URL can accept lead data, so keep it
   private and out of screenshots or demo videos.
2. In KnockQuest **CRM & Integrations → Zapier**, paste that URL, save the
   configuration, and press **Test Sync**. In Zapier, inspect the received test
   event and its `mappedLead` fields.
3. Add the **kvCORE/BoldTrail → Create Contact (Post)** action in Zapier. Connect
   the appropriate BoldTrail account and map first name, last name, email,
   phone, and address from `mappedLead`. Test the action with a disposable
   contact before publishing the Zap.
4. Turn on the Zap and enable **Auto-Sync Leads** in KnockQuest. New and updated
   leads then send webhook events. The app records delivery status and queues
   failed events for retry. A successful webhook response confirms Zapier
   received the event; check Zap history and BoldTrail to confirm contact creation.

Zapier's Webhooks trigger may require a paid Zapier plan. Check the plan shown
in the account before creating or upgrading anything.

For local browser testing, build with
`--dart-define=CRM_WEBHOOK_PROXY_URL=/crm-hook`, then serve `build/web` with
`python scripts/serve_web_with_crm_proxy.py --port 8769`. The script binds only
to localhost and relays only Zapier Catch Hook requests; it is a development
relay. A hosted web release needs its own authenticated server-side relay or
edge function because browsers cannot reliably POST directly to Zapier hooks
across origins. The Android app sends directly to the configured hook.

## Android Setup

The Android SDK and JDK are installed under `.toolchains` on D:. To check the
toolchain or build the staging APK, run:

```powershell
.\scripts\local_flutter.ps1 doctor
.\scripts\local_flutter.ps1 android
```

The APK is written to `build\app\outputs\flutter-apk\app-staging-debug.apk`.

## Build Flavors

Android flavors are configured:

- `staging`
- `production`

Run examples:

```powershell
flutter run --flavor staging --dart-define=APP_FLAVOR=staging
flutter run --flavor production --dart-define=APP_FLAVOR=production
```

Build examples:

```powershell
flutter build apk --flavor staging --dart-define=APP_FLAVOR=staging
flutter build apk --flavor production --dart-define=APP_FLAVOR=production
```

## Secrets and Credentials

- Never commit passwords, tokens, API keys, service account files, or keystore files.
- Keep runtime secrets in local `.env` files or platform secret stores.
- Use `.env.example` as a template only, with placeholder values.

## Commit Message Guidance

Use descriptive commits so non-technical stakeholders can follow progress clearly.

Format suggestion:

`<area>: <what changed> (<why>)`

Example:

`maps: add OpenStreetMap route polyline rendering (remove Google Maps cost dependency for MVP)`

## Project Standards

- Contributing guide: CONTRIBUTING.md
- Branch naming standard: BRANCHING.md
- Migration execution plan: MIGRATION_PLAN.md
- Issue label taxonomy: ISSUE_LABELS.md

## CI

GitHub Actions `verify` workflow runs on pull requests for all branches and pushes to `main`/`release/**` with:

- `scripts/run_github_ci_parity.ps1` (which runs pub get, migration guard, format, analyze, test, and web build)

## GitHub-Exclusive Mode

KnockQuest runtime code now treats GitHub as the single source of truth.

- Legacy builder references are blocked from runtime code by `scripts/verify_github_exclusive.ps1`.
- Placeholder reconstruction pages are blocked from active runtime routes.
- Unknown navigation paths now fail safely to a fallback screen instead of crashing route flow.
- All PRs are expected to pass formatting, analyze, tests, and release web build in Actions.

## Runtime Reliability Checks

- `test/widget_test.dart`: verifies login-to-dashboard happy path.
- `test/app_routes_smoke_test.dart`: verifies all named routes open and unknown routes are handled safely.
- `test/lead_flow_state_test.dart`: verifies Add Lead updates shared state and surfaces in Lead Details.
- `test/settings_interactions_test.dart`: verifies CRM toggles and subscription plan selection are interactive.

To run the same quality gates as GitHub Actions locally:

```powershell
./scripts/run_github_ci_parity.ps1
```

## GitHub Runbook

Two workflows now cover verification and release artifact generation:

- `.github/workflows/blank.yml` (`verify`)
	- triggers on pull requests for all branches and pushes to `main`/`release/**`
	- runs `scripts/run_github_ci_parity.ps1` as the canonical verification gate
	- cancels superseded runs on the same branch

- `.github/workflows/release_web_artifact.yml` (`release-web-artifact`)
	- triggers on pushes to `clean-final`, manually (`workflow_dispatch`), or on version tags (`v*`)
	- builds release web and Android artifacts with `APP_FLAVOR` set from workflow input
	- uploads `build/web` and `app-<flavor>-release.apk` as downloadable GitHub Actions artifacts
	- requires the repository variables `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` (both public client configuration)

- `.github/workflows/deploy_pages.yml` (`deploy-pages`)
	- triggers on pushes to `clean-final` and manual runs
	- checks the app, then builds Flutter web with the public Supabase settings and repository base href
	- publishes the app to GitHub Pages

Live app URL:

- `https://knockquestapp.github.io/KnockQuest/`

### Manual Release Artifact Run

1. Open GitHub Actions and run `release-web-artifact` on `clean-final`, or push a verified change to that branch.
2. Select `staging` or `production` flavor for a manual run. Branch and tag runs use `staging`.
3. Wait for the run to succeed. Sign in to GitHub, then download `knockquest-android-*` from the run's **Artifacts** section. GitHub downloads a ZIP; extract the APK before installing it.

For a direct APK download on a phone, use the latest test APK attached to the repository's [GitHub Releases](https://github.com/KnockQuestapp/KnockQuest/releases). Build that staging APK locally with `.\scripts\local_flutter.ps1 android-release -SupabaseUrl <project-url> -SupabasePublishableKey <public-key>`; the script keeps its toolchain and Gradle cache on D:. The test APK is signed with a debug key and is not a Play Store release.

### Environment And Secret Contract

Current build path is configured to run with dart defines and `.env.example` placeholders.
If future runtime integrations require credentials, store them as GitHub repository secrets and inject them in workflow steps instead of committing values to source.

Suggested secret naming convention for future use:

- `KNOCKQUEST_API_BASE_URL`
- `KNOCKQUEST_JWT_ISSUER`
- `KNOCKQUEST_JWT_AUDIENCE`
- `KNOCKQUEST_GOOGLE_MAPS_API_KEY`

## Release Tracking

- Changelog: CHANGELOG.md
- Current release draft: RELEASE_CANDIDATE_0.1.0.md

## Repository Hardening

After installing GitHub CLI and authenticating, run:

powershell
./scripts/github_hardening.ps1

This applies main-branch protection defaults and syncs issue labels.
