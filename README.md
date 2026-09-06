# SIGAP Flutter mobile app

Flutter client for the SIGAP citizen and field-worker flows. `SIGAP_Front-End` is the layout reference; demo jump navigation is intentionally excluded. The web administration SPA lives in `../kmipn-26-deno/web`.

## Run locally

The backend must already be running with Wrangler on port 8787.

- Android emulator: `flutter run` uses `http://10.0.2.2:8787` by default.
- Physical phone on the same network: run with `--dart-define=API_BASE_URL=http://YOUR_COMPUTER_LAN_IP:8787` and make the backend reachable on that interface.
- Deployed backend: build/run with `--dart-define=API_BASE_URL=https://YOUR_BACKEND_HOST`.
- Windows/browser development: the default is `http://localhost:8787`; the viewport remains mobile-sized. Native camera, GPS, storage and permission behavior still requires mobile-device testing.

Do not ship a release pointed at an emulator or localhost address. Pass the deployment URL explicitly when building the demo APK.

## Data and authentication

Reports, survey drafts and upload queues use Drift. Each authenticated account has a separate database; switching accounts preserves the previous account's pending data without exposing it to the next account. Older unscoped `sigap_db` files are not automatically attributed to an account or deleted.

The report form preserves its draft when saving fails. Offline report and queue insertion is transactional. Sync uploads local evidence before submitting report data, requires a server ID before marking an item synced, and retains failed payloads for retry. Survey retries carry a stable idempotency key; the backend deduplicates saved surveys and completed task actions.

Sync is controlled through the sync center. This version does not claim an installed WorkManager background service. AI assessments run only from explicit user actions.

The category catalog preserves backend string IDs and is cached for offline forms. Cached reports absent from a paginated server response are retained, not treated as deleted.

Notifications are in-app server records with persisted read state. Remote push delivery is not implemented. The visible inbox refreshes every 30 seconds and when the app resumes. Android local alerts for failed uploads request notification permission and follow the selected language; denied permissions and initialization failures cannot block sync or startup.

## Structure

- `lib/features/`: home, reports, tasks, cases, maps, profile, authentication, notifications, settings and administration scenes.
- `lib/api/`: requests, error handling and bounded token refresh. `lib/api/models/` groups the typed contracts by domain while preserving the public client import.
- `lib/providers/`: authenticated dependencies, settings, onboarding and data providers.
- `lib/db/`: account-scoped offline database and repositories.
- `lib/sync/`: queued report/survey submission.
- `lib/theme/`, `lib/l10n/`, `lib/widgets/`: shared presentation.

## Verification

Run `flutter test --no-pub`, `flutter analyze`, and `flutter build apk --debug --no-pub`. Build the APK again after generated localization or font assets change.

Tests cover offline submissions, rollback, cached catalog/report reads, account isolation, sync retries, token refresh, role routing, theme/language settings, notification data, mobile geometry and field workflows. Backend regression scripts in `../kmipn-26-deno/scripts` exercise real local HTTP flows. Live AI tests are separate, capped and paced because the configured free provider can rate-limit requests.
