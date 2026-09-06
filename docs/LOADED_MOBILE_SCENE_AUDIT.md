# Loaded mobile scene audit

Reference: `SIGAP_Front-End/src/mobile.js` (`reportForm`, `myReports`, `reportDetail`, `taskHome`, `taskDetail`, `surveyForm`) and `mobile.css`, including the phone breakpoint overrides; evidence ratios also use the later rules in `style.css`.

Rendered at 390 × 844 using production `SigapTheme` and bundled IBM Plex Sans/Mono fonts. The fixture supplies real-shaped typed records instead of API error responses. Screenshot baselines are Flutter regression artifacts, not proof of identical pixels against a browser screenshot.

| Scene | Source comparison and changes | Loaded verification |
|---|---|---|
| Report form | Five-step category/photo/location/condition/review order retained. Upload photo remains 1.3; review photo corrected to 1.8, matching the final `.photo-evidence` rule. Real image picker replaces demo-photo injection. | Category screen renders API categories, title input and continue action. Existing citizen tests cover named/anonymous offline submission and rollback. |
| Report list | Header, three filters, report card, status/date/location and create action follow the reference order. 20 px phone gutters retained. | A typed report with coordinates renders; existing filter test verifies Antrean changes the result set. |
| Report detail | Status notice, title, evidence, related case, timeline and additional-evidence request follow the reference order. Evidence corrected from 1.3 to 1.8 aspect ratio. | Loaded needs-completion record shows the requested-photo form; ratio asserted. |
| Task list | Replaced the custom 60 px header with the shared reference title bar. Removed an extra responsive-shell padding layer. Phone gutters now 20 px. Four compact filter pills fit the phone, save-all remains beside sorting. | One typed task renders title, unit, progress, deadline and save action; list is no longer an error shell. |
| Task detail | Replaced the 56 px custom header; removed double padding; 20 px page gutters, 14 px instruction-card padding, 18 px section gaps and 20 px case title. Moved actions after evidence/download notice inside the scrolling page. | Loaded instruction → checklist → citizen evidence order asserted. Existing task test persists checkbox state. |
| Survey form | Shared title bar with task/draft subtitle, 20 px gutters and 18 px field gaps. Photos → condition → GPS → dimensions → notes → recommendation → notice/actions order retained. Submit label reflects offline queue mode. | Loaded form renders in light/dark with production fonts. Typed checklist and route arguments replace dynamic maps; JSON remains only at persistence/transport boundaries. |

## Dark appearance and localization

Shared cards, GPS panel, notes field, report summaries/list items, metrics, search/filter overlays, authenticated shell, timeline, status tones and skeleton placeholders now resolve their colors from the active theme. Fullscreen photos intentionally retain a dark canvas with white controls, and white labels remain on fixed dark submit buttons. GPS and photo placeholders use existing translations.

## Evidence

- `test/loaded_mobile_scenes_test.dart`: 12 loaded renders (six scenes × light/dark), section-order and photo-ratio assertions.
- `test/goldens/loaded-*.png`: inspected first-viewport screenshots for those 12 renders.
- `test/mobile_locale_matrix_test.dart`: 132 renders (33 active scene shells × Indonesian/English × light/dark).
- Latest combined run: **173 passed**, `.run/final-scene-verification.log`; includes citizen/task functional tests, translation tests and the unchanged citizen-home golden.
- Focused analyzer: no issues in shared widgets, task features and loaded-scene tests.

## Precise limits and intentional real-app differences

- The initial six-scene fixtures exercise honest missing-photo states. A separate loaded-photo suite now supplies three valid PNG images through a local image HTTP adapter: report evidence is 1.8:1, task thumbnails are square, relative `/r2` paths resolve to the API host, viewer opening/swiping/counters/decoded image display/back navigation work in both themes. This does not test native camera/GPS permissions or offline media availability.
- New loaded screenshot baselines cover the first viewport, not every scroll position, dropdown/menu or dialog. Existing action tests supplement them, but do not turn these into full pixel-identical browser comparisons.
- Categories, report counts, instructions, names, deadlines, SLA availability and timelines come from actual records. Demo identities, simulated coordinates, fabricated photos, jump buttons and fake synchronization states are excluded.
- Flutter uses native input, selection, focus and button behavior. Native controls still differ in some decoration and interaction details from HTML controls; this audit does not label those pixels 1:1.
- Survey uses a real GPS capture action instead of a prefilled simulated coordinate notice. Task action permissions and status transitions remain enforced. With no SLA data, task detail shows the actual task state rather than an invented SLA badge.

## Loaded-photo follow-up

`test/loaded_photo_gallery_test.dart` adds four light/dark report/task tests. All four plus the twelve loaded-scene regressions pass (**16/16**, `.run/photo-gallery.log`). The image adapter supplies actual decodable raster bytes without network access. Screenshots `test/goldens/photos-{report,task}-{light,dark}.png` show loaded evidence; `photo-viewer-{report,task}-{light,dark}.png` show the second image after swiping. Report photos now open the same viewer as task photos; task rendering normalizes relative image paths and uses square thumbnails. Focused analyzer reports no issues.
