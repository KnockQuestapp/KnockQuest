# KnockQuest

KnockQuest is the source-controlled Flutter application maintained and delivered exclusively from GitHub.

## Tech Stack

- Flutter stable 3.44.8
- Dart 3.12.2
- Targets: Android, iOS, Web, Windows, Linux, macOS

## Quick Start

1. Install Flutter SDK (stable channel).
2. In the project root, run:

	```powershell
	flutter pub get
	flutter run -d windows
	```

3. For web testing:

	```powershell
	flutter run -d chrome
	```

## Android Setup

`flutter doctor -v` reports Android SDK as missing until Android Studio and the SDK are installed.

1. Install Android Studio.
2. Complete first-run Android SDK setup.
3. If needed, configure SDK path:

	```powershell
	flutter config --android-sdk "C:\Users\Administrator\AppData\Local\Android\Sdk"
	```

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
	- triggers manually (`workflow_dispatch`) or on version tags (`v*`)
	- builds release web and Android artifacts with `APP_FLAVOR` set from workflow input
	- uploads `build/web` and `app-<flavor>-release.apk` as downloadable GitHub Actions artifacts

### Manual Release Artifact Run

1. Open GitHub Actions and run `release-web-artifact`.
2. Select `staging` or `production` flavor.
3. Download the uploaded `knockquest-web-*` and `knockquest-android-*` artifacts from the completed run.

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
