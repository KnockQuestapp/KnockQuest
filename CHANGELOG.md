# Changelog

## 0.1.0 - 2026-08-03

### Added

- Migrated repository to a structured Flutter codebase.
- Implemented baseline app shell with Map and Quests tabs.
- Added OpenStreetMap integration using `flutter_map`.
- Added config hooks for future Google Maps enablement.
- Added staging/production flavor support on Android.
- Added security hardening files and credential-safe defaults.
- Added CI workflow for `flutter analyze` and `flutter test`.
- Added contribution standards, branch naming conventions, issue templates, and label taxonomy.

### Security

- Added `.env` protection patterns in git ignore policy.
- Added vulnerability reporting and secret management policy.

### Notes

- Android SDK installation is still required on contributor machines for Android builds.
- Any credentials previously shared outside secure channels should be rotated.
