# Contributing to KnockQuest

## Branching

Create all feature and fix work from `main` into a topic branch.

Use this naming format:

- `feature/<scope>-<short-description>`
- `fix/<scope>-<short-description>`
- `chore/<scope>-<short-description>`
- `docs/<scope>-<short-description>`

Example: `feature/maps-osm-routing`

## Commit Messages

Use descriptive, investor-readable commit messages:

`<area>: <what changed> (<why>)`

Examples:

- `auth: add admin role guard for migration screens (protect privileged actions)`
- `maps: replace paid provider with OpenStreetMap baseline (reduce MVP cost)`

## Pull Request Checklist

1. Pull latest `main` and rebase your branch.
2. Run locally:
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`
3. Ensure no secrets are included.
4. Include screenshots or short screen recording for UI changes.
5. Reference issue number in PR description.

## Security Rules

- Never commit credentials, tokens, API keys, keystore files, or private certs.
- If a secret is exposed, rotate it immediately and notify maintainers.
- Use `.env.example` placeholders only; real values belong in local `.env`.
