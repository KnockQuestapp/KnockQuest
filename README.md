# KnockQuest

KnockQuest is the source-controlled Flutter application migrated from the previous FlutterFlow workflow.

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

GitHub Actions workflow runs on pushes and pull requests to `main` with:

- `flutter pub get`
- `flutter analyze`
- `flutter test`

## Release Tracking

- Changelog: CHANGELOG.md
- Current release draft: RELEASE_CANDIDATE_0.1.0.md
