# KnockQuest Migration Plan

## Objective

Migrate from FlutterFlow-driven development to a source-controlled Flutter codebase with clear delivery visibility, security hygiene, and CI enforcement.

## Completed Baseline

- Flutter project initialized in repository
- OpenStreetMap baseline integrated for map view
- Security policy and secret-handling defaults added
- Branching and contribution standards defined
- GitHub Actions pipeline added for analyze and test
- Issue templates and label taxonomy prepared

## Phase 1: Foundation Hardening

Status: In progress

1. Finalize app identity values:
   - Android package id
   - iOS bundle id
   - Display name and launcher icons
2. Add environment loading strategy for non-committed runtime config
3. Configure GitHub repository labels from ISSUE_LABELS.md

## Phase 2: FlutterFlow Parity

Status: Pending

1. Inventory screens and flows from the current FlutterFlow app
2. Rebuild each screen in Flutter with component ownership by feature folder
3. Recreate authentication and role logic
4. Validate admin permissions and collaborator access paths

## Phase 3: Routing and Maps Strategy

Status: Pending

1. Keep OSM as default map provider for MVP cost control
2. Add route polyline and turn-by-turn view if needed
3. Add optional Google Maps provider behind config flag and key checks

## Phase 4: Release Readiness

Status: Pending

1. Add staging and production build flavors
2. Add semantic version and release tagging flow
3. Add crash monitoring and analytics policy
4. Publish investor-readable milestone notes per release

## Definition of Done

- All critical FlutterFlow user journeys are reproduced
- CI passes on pull requests
- No secrets in repo history
- README and CONTRIBUTING reflect real workflows
- First tagged release candidate built for target platforms
