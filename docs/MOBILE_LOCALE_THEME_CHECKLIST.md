# Mobile localization and theme verification

Viewport: 390 × 844, device pixel ratio 1. Production SigapTheme.light/dark; Indonesian and English. All 33 active screen constructors are covered by mobile_locale_matrix_test.dart. API fixture returns an unavailable response; no live AI calls.

These checks verify rendered shells and error/empty states, layout exceptions, and known untranslated action labels. They do not certify loaded data, every modal, native permissions, or pixel-for-pixel visual parity. Existing workflow tests cover separate data actions.

Current snapshot: 135 passed / 0 failed: 132 screen matrix cases, two localized-copy tests, and the existing citizen-home screenshot golden. The golden baseline was not changed.

| Scene | Indonesian light | Indonesian dark | English light | English dark |
|---|---|---|---|---|
| AccountsScreen | PASS | PASS | PASS | PASS |
| CategoriesScreen | PASS | PASS | PASS | PASS |
| PriorityConfigScreen | PASS | PASS | PASS | PASS |
| RegionalDashboardScreen | PASS | PASS | PASS | PASS |
| SlaScreen | PASS | PASS | PASS | PASS |
| UnitsScreen | PASS | PASS | PASS | PASS |
| AiConsoleScreen | PASS | PASS | PASS | PASS |
| StatisticsScreen | PASS | PASS | PASS | PASS |
| AuditLogScreen | PASS | PASS | PASS | PASS |
| LoginScreen | PASS | PASS | PASS | PASS |
| RegisterScreen | PASS | PASS | PASS | PASS |
| CaseQueueScreen | PASS | PASS | PASS | PASS |
| CaseReviewScreen | PASS | PASS | PASS | PASS |
| CaseWorkspaceScreen | PASS | PASS | PASS | PASS |
| DashboardScreen | PASS | PASS | PASS | PASS |
| ExportScreen | PASS | PASS | PASS | PASS |
| HomeScreen | PASS | PASS | PASS | PASS |
| MapPickerScreen | PASS | PASS | PASS | PASS |
| MapScreen | PASS | PASS | PASS | PASS |
| NotificationsScreen | PASS | PASS | PASS | PASS |
| OnboardingScreen | PASS | PASS | PASS | PASS |
| ProfileScreen | PASS | PASS | PASS | PASS |
| CreateReportScreen | PASS | PASS | PASS | PASS |
| ReportAppealScreen | PASS | PASS | PASS | PASS |
| ReportDetailScreen | PASS | PASS | PASS | PASS |
| ReportEvidenceScreen | PASS | PASS | PASS | PASS |
| ReportHistoryScreen | PASS | PASS | PASS | PASS |
| ReportListScreen | PASS | PASS | PASS | PASS |
| ReportSubmissionReviewScreen | PASS | PASS | PASS | PASS |
| SettingsScreen | PASS | PASS | PASS | PASS |
| SyncCenterScreen | PASS | PASS | PASS | PASS |
| SurveyFormScreen | PASS | PASS | PASS | PASS |
| TaskWorkspaceScreen | PASS | PASS | PASS | PASS |


Static localization audit: no missing English ARB keys; removed unused merge-placeholder copy; Indonesian status/action/error strings translated; distinct submitted/review/verified/in-progress labels retained. Server names and descriptions remain unmodified.

Theme audit: AI console, audit, statistics, export, regional dashboard, appeal and evidence use contextual neutral palettes. White foregrounds on fixed dark buttons and photo overlays intentionally remain white. Map controls now use contextual neutral palettes; their focused id/en light/dark matrix passes 8/8. Shared widgets are handled by the layout audit.



