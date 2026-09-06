# Mobile language and UX prose review — 7 September 2026

## Scope and verification limits
This is a source review of every current Flutter feature and shared-widget file, plus Indonesian/English ARB sources and semantic label helpers. Navigation labels and status chips remain concise where appropriate; adjacent explanations describe actions and limits. Stored citizen/operator notes, measurement values, custom category names and checklist text remain unchanged.

The active mobile route tree contains citizen and field-worker experiences. It has no current admin AI console, priority editor or administrative audit screen; those removed screens were not recreated. The web team owns those experiences.

No mobile tests, golden runs, build, install or ADB actions occurred in this review. Localization classes were generated from ARB with gen-l10n. An intermediate analyzer completed with zero issues. Root owns the final analyzer after the shared formatting boundary. Changed copy has not received runtime/narrow-viewport visual verification in this review, per the user's instruction.

## Concrete changes
- Rewrote more than190 bilingual message entries across permissions, reporting, survey, privacy, synchronization, errors and task stages. Generated files are tool output, not handwritten edits.
- Report detail explains the recorded status; completion/submission does not imply verification. It displays actual stored address and valid zero-valued coordinates, and explains missing photos/addresses.
- Task detail tells staff how to compare report evidence with observations. Completed task results read “SIGAP menerima hasil”; report resolution remains a separate stage. No inferred individual actor.
- Removed the unused public-identity toggle: its value never reached a request, so it could not fulfill the promised behavior. The review now explains actual identity protection and asks people to review photo/description content.
- Settings reads the existing internet reachability provider for device connectivity; it no longer claims the server is always online. Removed an incorrect fixed v1.0.0 badge (pubspec is0.1.0+1).
- Empty/missing totals and similarity percentages no longer appear as invented zeroes or empty metric cards; available values remain visible. Progress percentage never substitutes for a count.
- Errors give retry guidance and retain technical details in an optional disclosure/action. A failed queue read cannot display “all sent”.
- The active /evidence/:caseId route now sends selected image bytes and description through addReportEvidence; removed the literal evidence-upload-token and split upload/empty evidence action.
- Bilingual report-list filters and locale-aware dates replace fixed Indonesian labels/date formatting. Survey history parses server timestamps as UTC before local display.

## File inventory
“Reviewed” below means source/copy review, not a runtime pass. Shared layout primitives without owned prose were checked for displayed literal text and retain caller-supplied content.

| File | Review outcome |
| --- | --- |
| `lib/features/analytics/statistics_screen.dart` | Added scope explanation; show available counts without empty totals; localized categories/statuses and error detail disclosure. |
| `lib/features/auth/login_screen.dart` | Reviewed sign-in/register instructions, validation and bilingual labels; preserve structured authentication errors. |
| `lib/features/auth/register_screen.dart` | Reviewed sign-in/register instructions, validation and bilingual labels; preserve structured authentication errors. |
| `lib/features/home/citizen_home_view.dart` | Replaced slogans/blanket privacy and delivery promises with active guidance; wrapped longer queue explanation. |
| `lib/features/home/home_screen.dart` | Replaced slogans/blanket privacy and delivery promises with active guidance; wrapped longer queue explanation. |
| `lib/features/map/map_picker_screen.dart` | Explain public approximate locations versus task coordinates; preserve real recorded points; show retry guidance and optional technical errors. |
| `lib/features/map/map_screen.dart` | Explain public approximate locations versus task coordinates; preserve real recorded points; show retry guidance and optional technical errors. |
| `lib/features/map/report_map_widget.dart` | Explain public approximate locations versus task coordinates; preserve real recorded points; show retry guidance and optional technical errors. |
| `lib/features/notifications/notifications_screen.dart` | Explain inbox actions; keep backend/user message content unchanged; raw action failures move to optional details. |
| `lib/features/onboarding/onboarding_screen.dart` | Explain why each permission helps and how to change it without promising results. |
| `lib/features/profile/profile_screen.dart` | Clarify account context and device connectivity; theme/language controls keep concise labels. |
| `lib/features/reports/create_report_screen.dart` | Add stage-specific report explanations, actual address, related-report guidance, reviewed submission/evidence/appeal prose and truthful local-draft state. Use authenticated multipart evidence endpoint. |
| `lib/features/reports/models/report_item.dart` | Add stage-specific report explanations, actual address, related-report guidance, reviewed submission/evidence/appeal prose and truthful local-draft state. Use authenticated multipart evidence endpoint. |
| `lib/features/reports/report_appeal_screen.dart` | Add stage-specific report explanations, actual address, related-report guidance, reviewed submission/evidence/appeal prose and truthful local-draft state. Use authenticated multipart evidence endpoint. |
| `lib/features/reports/report_detail_screen.dart` | Add stage-specific report explanations, actual address, related-report guidance, reviewed submission/evidence/appeal prose and truthful local-draft state. Use authenticated multipart evidence endpoint. |
| `lib/features/reports/report_evidence_screen.dart` | Add stage-specific report explanations, actual address, related-report guidance, reviewed submission/evidence/appeal prose and truthful local-draft state. Use authenticated multipart evidence endpoint. |
| `lib/features/reports/report_history_screen.dart` | Add stage-specific report explanations, actual address, related-report guidance, reviewed submission/evidence/appeal prose and truthful local-draft state. Use authenticated multipart evidence endpoint. |
| `lib/features/reports/report_list_screen.dart` | Add stage-specific report explanations, actual address, related-report guidance, reviewed submission/evidence/appeal prose and truthful local-draft state. Use authenticated multipart evidence endpoint. |
| `lib/features/reports/report_submission_review_screen.dart` | Add stage-specific report explanations, actual address, related-report guidance, reviewed submission/evidence/appeal prose and truthful local-draft state. Use authenticated multipart evidence endpoint. |
| `lib/features/reports/widgets/report_review_app_bar.dart` | Add stage-specific report explanations, actual address, related-report guidance, reviewed submission/evidence/appeal prose and truthful local-draft state. Use authenticated multipart evidence endpoint. |
| `lib/features/settings/settings_screen.dart` | Replace fixed server-online claim with measured device connection; remove incorrect hardcoded version; generate push-permission copy from ARB. |
| `lib/features/sync/sync_center_screen.dart` | Distinguish device queue from all saved data and delivery; do not show empty-success state after queue load failure; optional technical errors. |
| `lib/features/tasks/survey_form_screen.dart` | Explain recorded location, instructions, checklist, photos, submitted visits and admin review; separate sent results from resolved reports; preserve notes/measurements. |
| `lib/features/tasks/task_workspace_screen.dart` | Explain recorded location, instructions, checklist, photos, submitted visits and admin review; separate sent results from resolved reports; preserve notes/measurements. |
| `lib/widgets/adaptive_nav.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/a11y.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/authenticated_shell.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/back_arrow_button.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/catatan_lapangan.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/design_system.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/gps_capture_card.dart` | Explain device accuracy/time limits without claiming location proves facility condition. |
| `lib/widgets/design_system/metric_card.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/mobile_title_bar.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/photo_full_screen.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/progress_metric_card.dart` | Show actual available metrics; no empty counts or percentage-as-count fallback. |
| `lib/widgets/design_system/report_summary_card.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/responsive.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/responsive_scaffold.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/role_banner.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/section_label.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/sigap_app_bar.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/sigap_card.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/sigap_search_bar.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/similar_cases_banner.dart` | Explain nearby similarity is not identity; hide unavailable metrics and retain actual values. |
| `lib/widgets/design_system/status_grid.dart` | Show actual available metrics; no empty counts or percentage-as-count fallback. |
| `lib/widgets/design_system/stepper_5.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/sticky_footer_cta.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/sync_status_indicator.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/timeline_event.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/design_system/truth_statement_checkbox.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/facility_icon.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/mobile_viewport.dart` | Shared presentation: reviewed owned labels and caller-provided content; ARB supplies localized prose. |
| `lib/widgets/push_notification_settings.dart` | Migrated all hardcoded bilingual push settings to generated ARB messages; preserve real push state. |
| `lib/widgets/request_error_details.dart` | New reusable retry guidance with optional technical details; raw errors remain accessible. |

Additional sources reviewed/edited: lib/l10n/app_id.arb, app_en.arb, status_label.dart, category_label.dart, report_condition_label.dart. Removed unreferenced lib/widgets/design_system/privacy_toggle.dart. Generated outputs under lib/l10n/generated come only from gen-l10n.

## Remaining dependencies and explicit limits
- Backend-authored notifications provide title/body strings, not stable localization keys/parameters; English cannot be guaranteed for those stored messages. Root owns the backend contract follow-up. Do not overwrite user messages with guesses.
- Custom checklist labelEn is optional. The UI preserves an operator label if no translation exists.
- The current mobile task DTO does not expose a reliable acting-user identity for every shared-unit task. Copy uses the known service/role or describes the state without claiming that the signed-in person performed the action.
- Runtime layout and the repaired evidence submission are not newly exercised because mobile runtime testing is paused. The selected file and description now follow the already-established authenticated API contract; final analyzer checks source consistency only.
- Optional key/value facts (actual coordinates, measurements, timestamps) remain available with surrounding explanation; no prose invents missing evidence, address, score, worker or outcome.
