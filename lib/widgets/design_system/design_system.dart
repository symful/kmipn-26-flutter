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

export 'sync_status_indicator.dart';

export 'responsive_scaffold.dart';

export 'sigap_app_bar.dart';
export '../adaptive_nav.dart';

// Migrated sibling widgets (F1-6, F1-7, F1-10)

export 'role_banner.dart';

// Photo viewer
export 'photo_full_screen.dart';

// AppBar widgets
export 'back_arrow_button.dart';
export 'sigap_search_bar.dart';

// Shell widgets
export 'authenticated_shell.dart';

// Section label
export 'section_label.dart';

// Extracted reusable widgets
export 'metric_card.dart';
export 'progress_metric_card.dart';
