# Mobile parity and validation

## Supported mobile roles

Flutter serves **Warga and Petugas only**. Admin uses the web application. Mobile login and restored sessions reject Admin and unknown roles; navigation uses a mobile-role allowlist. Demo quick-login chips remain available for Warga and Petugas.

## Screen inventory

| Flow | Screens |
|---|---|
| Authentication | Login, registration, onboarding |
| Citizen | Home, report list/detail, create report, submission review, appeal, evidence |
| Field work | Task list/detail, survey form, completed-task history |
| Shared | Map, location picker, sync center, notifications, public statistics, profile, settings |

Admin categories/accounts/units/SLA/priority configuration, case review/workspace/queue, government dashboard, AI console, audit and export screens and their routes were removed. Their dedicated widget tests were removed with the features. Shared citizen and field-worker tests remain.

## Data source corrections

- Public statistics read distinct report and case totals and the actual overdue-SLA count; at-risk cases are not counted as overdue. Missing values do not become zero.
- Server reports without GPS remain in report lists. Missing or invalid creation dates do not become today's date.
- Survey GPS uses measured accuracy and the original capture timestamp, persisted with the draft. A draft lacking accuracy requires recapture; it does not claim six-meter accuracy.
- Submission review receives actual condition, GPS accuracy, capture time and impact data, displays its real photo, and requests similar reports from the location/category endpoint. It does not assume severe damage, good accuracy or three photos.
- Sync uploads omit legacy database population/vulnerability defaults unless real values were recorded in the queued payload.
- Authenticated device telemetry posts measured local report counts to `/api/sync/status`, with a persistent device UUID. It runs on startup, debounced report changes, reconnect and manual sync completion. Upload failures do not block report synchronization.

## Verification

- `test/mobile_roles_test.dart`: rejects Admin/unknown roles, accepts Warga/Petugas, verifies the two demo chips.
- `test/data_wiring_test.dart`: distinct backend metrics, missing-data handling and reports without metadata.
- `test/sync_telemetry_test.dart`: real local counts, startup/change/reconnect publication, bounded behavior and failure isolation.
- `test/map_interaction_test.dart`: four tests.
- Locale/theme matrix covers remaining mobile scenes in Indonesian/English and light/dark themes.
- Loaded scene images demonstrate rendered states; they do not establish pixel-perfect parity with every design reference. The photo-gallery tests retain dedicated pixel comparisons and swipe checks.

After the connected-workflow and Firebase fixes, 179 tests passed (the opt-in live harness is skipped in a normal run), analysis reported no issues, and the Firebase-enabled debug APK built successfully (201,903,857 bytes). Logs are stored under `.run/` and the APK is `build/app/outputs/flutter-apk/app-debug.apk`.

### Connected workflow harness

`test/live_connected_workflow_test.dart` is opt-in through `--dart-define=LIVE_WORKFLOW_STAGE=submit`, `visit`, or `warga-check`. It uses the real Flutter `ApiClient`, typed response models, and HTTP against the local server on port 8787. Normal test runs skip it. The submit stage writes a token-free handoff manifest to `.run/live-workflow.json`; Admin web steps happen between mobile stages. The input image, EXIF location/time, and visit measurements are explicitly synthetic test inputs. This is API integration evidence, not Android device interaction evidence.

The submission timestamp accepts a typed `DateTime` and serializes UTC to both report creation routes; `test/report_timestamp_test.dart` verifies the contract.

The connected local workflow completed for report `cabbeab1fef6` and task `de973613f7bb`: Warga uploaded/submitted, Admin reviewed and assigned in the web UI, Petugas accepted/started/uploaded a visit/completed through the Flutter client, Admin approved in the web UI, and Warga read the resolved report and related notifications through the Flutter client. The workflow found and fixed a checklist DTO field mismatch (`item` versus `label`). Category checklist actions are now read from persisted server configuration; a missing configuration is shown explicitly and does not invent mandatory actions.

### Android push notifications

Firebase Messaging uses the supplied Android app configuration through the Google Services build plugin. Users opt in under Settings → Device notifications. The app requests Android permission, registers the actual FCM token with the authenticated device endpoint, refreshes registration when tokens change or the app resumes, and deregisters/deletes the token on logout or disable. Foreground messages refresh the inbox and show a generic native notification. Android displays background notification payloads; the background Dart handler also supports account-checked data-only messages. Notification taps open the authenticated inbox, including cold launches. Lock-screen alerts contain generic copy rather than report details.

`test/push_notifications_test.dart` verifies recipient isolation, registration/removal request contracts, and Indonesian/English permission controls in light/dark appearance. Native device delivery requires an installed APK, notification permission, Google Play services, and a backend configured to send through the same Firebase project. Automated Flutter tests and APK compilation do not by themselves prove receipt on a physical device.

## Physical Android checks (6 September 2026)

On the authorized OPPO CPH2631, actual SIGAP foreground and background notifications arrived after real report acceptance events; tapping the native notification opened the authenticated inbox. SQLite UTC timestamp parsing now shows fresh events as “Baru saja” and older events in minutes. Evidence is in `.run/phone-final-timestamp-inbox.png`.

Automatic native internet loss and recovery were observed as Offline then Online without an app toggle. Original Wi-Fi and SIM data states were restored. Evidence: `.run/phone-no-internet.png` and `.run/phone-recovered-online.png`. A later immediate submission during the connectivity transition exposed a stale online-state race; the submission now checks current native reachability before choosing the offline queue. The focused regression covers this race. The physical retry then queued the labeled photo report while Offline and successfully synced one report after recovery (`phone-offline-queue-fixed.png`, `phone-sync-success.png`).

Account now provides an inbox entry. Physical light/dark and English switching revealed and fixed a tab reset on inherited theme/locale changes; Account now remains selected. Evidence: `.run/phone-dark-english.png`. The Android adaptive icon and cold splash were verified without the reported white surround in `.run/phone-settings-adaptive-icon.png` and `.run/phone-adaptive-cold-launch.png`.

