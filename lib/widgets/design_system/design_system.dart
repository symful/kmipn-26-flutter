/// SIGAP Design System
///
/// Canonical barrel export for all design system widgets.
/// Import design_system widgets via this file to ensure
/// consistent access across the codebase.
///
/// Usage:
/// ```dart
/// import 'package:sigap/widgets/design_system/design_system.dart';
/// ```
library;

// Accessibility
export 'a11y.dart';

// Foundation widgets (F1-1 through F1-9)
export 'responsive.dart';
export 'sigap_card.dart';
export 'status_pill.dart';
export 'sync_status_indicator.dart';
export 'empty_state_view.dart';
export 'responsive_scaffold.dart';
export 'sticky_action_bar.dart';
export 'stat_grid.dart';
export 'sigap_app_bar.dart';
export 'sigap_bottom_nav.dart';

// Migrated sibling widgets (F1-6, F1-7, F1-10)
export 'error_retry_view.dart';
export 'skeleton_loaders.dart';
export 'role_banner.dart';
export 'priority_score_card.dart';
export 'ai_assessment_card.dart';

// Section widgets
export 'section_header.dart';

// Report / case list item
export 'report_list_item.dart';

// AppBar widgets
export 'back_arrow_button.dart';
export 'title_app_bar.dart';

// State management helpers
export 'async_data_widget.dart';
export 'pending_sync_banner.dart';

// Shell widgets
export 'authenticated_shell.dart';
