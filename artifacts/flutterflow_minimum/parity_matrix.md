# FlutterFlow Minimum Parity Matrix

This matrix maps each required capture artifact to the exact KnockQuest code target that will be updated.

## Priority 1: Auth + Backend

| Queue Item | KnockQuest Target | Expected Change | Status |
| --- | --- | --- | --- |
| `pages/LoginRegistration/widget-tree.png` | `lib/src/features/auth/login_registration_page.dart` | Match full layout, widget order, copy, spacing, and visibility rules. | Implemented (layout parity pass) |
| `pages/LoginRegistration/action-login.png` | `lib/src/features/auth/login_registration_page.dart` | Replace current login handler with exact action chain (validation, auth call, navigation, error handling). | Captured, action details not visible |
| `pages/LoginRegistration/action-google-signin.png` | `lib/src/features/auth/login_registration_page.dart` | Implement exact Google auth action flow and post-login route behavior. | Captured, action details not visible |
| `backend/auth-providers.png` | `lib/src/features/auth/login_registration_page.dart`, `pubspec.yaml` | Wire only enabled auth providers and required packages/config flags. | Missing valid capture |
| `backend/collections-overview.png` | `lib/src/sample_data.dart`, lead/follow-up/territory pages | Replace sample model assumptions with real collection names/relationships. | Captured (partial: Lead/Territory/Visit list) |
| `backend/users-fields.png` | `lib/src/features/auth/login_registration_page.dart`, shared user model (new) | Add real user field mapping, defaults, and null/required handling. | Missing valid capture |
| `backend/leads-fields.png` | `lib/src/features/leads/add_lead_page.dart`, `lib/src/features/leads/lead_details_page.dart` | Align lead create/read fields with backend schema and real data types. | Implemented (schema-aligned fields) |

## Priority 2: Main Dashboard + Lead Flow

| Queue Item | KnockQuest Target | Expected Change | Status |
| --- | --- | --- | --- |
| `pages/MainDashboard/widget-tree.png` | `lib/src/features/dashboard/main_dashboard_page.dart` | Match exact dashboard structure, cards, labels, and section hierarchy. | Missing valid capture |
| `pages/MainDashboard/action-add-lead.png` | `lib/src/features/dashboard/main_dashboard_page.dart` | Mirror add-lead trigger action chain and arguments. | Behavior implemented, missing valid capture |
| `pages/MainDashboard/action-open-map.png` | `lib/src/features/dashboard/main_dashboard_page.dart` | Mirror open-map action and any parameter/state transfer. | Captured and implemented |
| `pages/MainDashboard/action-follow-ups.png` | `lib/src/features/dashboard/main_dashboard_page.dart` | Mirror follow-ups action and any filters/context passed. | Captured and implemented |
| `pages/AddLead/widget-tree.png` | `lib/src/features/leads/add_lead_page.dart` | Match exact add-lead form structure, defaults, and field-level UX. | Behavior implemented, missing valid capture |
| `pages/AddLead/action-save-lead.png` | `lib/src/features/leads/add_lead_page.dart` | Implement exact create-document/action pipeline and success/error transitions. | Behavior implemented, missing valid capture |

## Priority 3: Map Behavior

| Queue Item | KnockQuest Target | Expected Change | Status |
| --- | --- | --- | --- |
| `pages/InteractiveMap/widget-tree.png` | `lib/src/features/map/interactive_map_page.dart` | Match widget layering, controls, legends, and default viewport settings. | Behavior implemented, missing valid capture |
| `pages/InteractiveMap/action-draw-boundary.png` | `lib/src/features/map/interactive_map_page.dart` | Implement exact boundary-draw action flow and persisted state updates. | Behavior implemented, missing valid capture |

## Immediate Execution Trigger

After any new files are dropped into `artifacts/flutterflow_minimum`, run:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\summarize_flutterflow_minimum_capture.ps1
```

Then I will apply the corresponding parity edits in code for all newly available rows.
