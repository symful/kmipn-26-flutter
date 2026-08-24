import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Shared icon components for consistent iconography across the app.
/// Uses Material Icons with PantauDesa teal primary color.
class AppIcons {
  AppIcons._();

  // ============================================================================
  // Status Icons
  // ============================================================================

  static const Icon warning = Icon(
    Icons.warning_amber_rounded,
    color: SigapColors.warning,
  );

  static const Icon warningOutlined = Icon(
    Icons.warning_amber_outlined,
    color: SigapColors.warning,
  );

  static const Icon error = Icon(Icons.error_outline, color: SigapColors.danger);

  static const Icon errorFilled = Icon(Icons.error, color: SigapColors.danger);

  static const Icon success = Icon(
    Icons.check_circle_outline,
    color: SigapColors.primary,
  );

  static const Icon successFilled = Icon(
    Icons.check_circle,
    color: SigapColors.primary,
  );

  static const Icon info = Icon(Icons.info_outline, color: SigapColors.info);

  static const Icon infoFilled = Icon(Icons.info, color: SigapColors.info);

  // ============================================================================
  // Navigation Icons
  // ============================================================================

  static const Icon chevronRight = Icon(
    Icons.chevron_right,
    color: SigapColors.textSecondary,
  );

  static const Icon chevronLeft = Icon(
    Icons.chevron_left,
    color: SigapColors.textSecondary,
  );

  static const Icon arrowBack = Icon(
    Icons.arrow_back,
    color: SigapColors.textPrimary,
  );

  static const Icon home = Icon(
    Icons.home_outlined,
    color: SigapColors.textSecondary,
  );

  static const Icon homeFilled = Icon(Icons.home, color: SigapColors.primary);

  // ============================================================================
  // Action Icons
  // ============================================================================

  static const Icon camera = Icon(Icons.add_a_photo, color: SigapColors.primary);

  static const Icon cameraOutlined = Icon(
    Icons.add_a_photo_outlined,
    color: SigapColors.textSecondary,
  );

  static const Icon location = Icon(
    Icons.location_on,
    color: SigapColors.primary,
  );

  static const Icon locationOutlined = Icon(
    Icons.location_on_outlined,
    color: SigapColors.textSecondary,
  );

  static const Icon report = Icon(
    Icons.description_outlined,
    color: SigapColors.textSecondary,
  );

  static const Icon reportFilled = Icon(
    Icons.description,
    color: SigapColors.primary,
  );

  static const Icon add = Icon(Icons.add, color: SigapColors.primary);

  static const Icon edit = Icon(
    Icons.edit_outlined,
    color: SigapColors.textSecondary,
  );

  static const Icon delete = Icon(
    Icons.delete_outline,
    color: SigapColors.danger,
  );

  static const Icon refresh = Icon(
    Icons.refresh,
    color: SigapColors.textSecondary,
  );

  static const Icon sync = Icon(Icons.sync, color: SigapColors.primary);

  // ============================================================================
  // Map & Location Icons
  // ============================================================================

  static const Icon map = Icon(
    Icons.map_outlined,
    color: SigapColors.textSecondary,
  );

  static const Icon mapFilled = Icon(Icons.map, color: SigapColors.primary);

  static const Icon myLocation = Icon(
    Icons.my_location,
    color: SigapColors.primary,
  );

  // ============================================================================
  // List & Queue Icons
  // ============================================================================

  static const Icon list = Icon(Icons.list, color: SigapColors.textSecondary);

  static const Icon inbox = Icon(Icons.inbox, color: SigapColors.textSecondary);

  static const Icon inboxOutlined = Icon(
    Icons.inbox_outlined,
    color: SigapColors.textSecondary,
  );

  static const Icon queue = Icon(Icons.queue, color: SigapColors.primary);

  // ============================================================================
  // Category & Tag Icons
  // ============================================================================

  static const Icon category = Icon(
    Icons.category_outlined,
    color: SigapColors.textSecondary,
  );

  static const Icon categoryFilled = Icon(
    Icons.category,
    color: SigapColors.primary,
  );

  static const Icon tag = Icon(Icons.tag, color: SigapColors.textSecondary);

  // ============================================================================
  // User & Role Icons
  // ============================================================================

  static const Icon person = Icon(
    Icons.person_outline,
    color: SigapColors.textSecondary,
  );

  static const Icon personFilled = Icon(Icons.person, color: SigapColors.primary);

  static const Icon verified = Icon(
    Icons.verified_outlined,
    color: SigapColors.primary,
  );

  static const Icon verifiedFilled = Icon(
    Icons.verified,
    color: SigapColors.primary,
  );

  static const Icon people = Icon(
    Icons.people_outline,
    color: SigapColors.textSecondary,
  );

  // ============================================================================
  // Communication Icons
  // ============================================================================

  static const Icon email = Icon(
    Icons.email_outlined,
    color: SigapColors.textSecondary,
  );

  static const Icon lock = Icon(
    Icons.lock_outlined,
    color: SigapColors.textSecondary,
  );

  static const Icon visibility = Icon(
    Icons.visibility_outlined,
    color: SigapColors.textSecondary,
  );

  static const Icon visibilityOff = Icon(
    Icons.visibility_off_outlined,
    color: SigapColors.textSecondary,
  );

  // ============================================================================
  // Status Indicator Icons (for ListTiles, Cards, etc.)
  // ============================================================================

  static const Icon perluTindakan = Icon(
    Icons.pending_actions,
    color: SigapColors.danger,
  );

  static const Icon diproses = Icon(
    Icons.pending_outlined,
    color: SigapColors.info,
  );

  static const Icon selesai = Icon(
    Icons.check_circle_outline,
    color: SigapColors.primary,
  );

  static const Icon timer = Icon(
    Icons.timer_outlined,
    color: SigapColors.textSecondary,
  );

  // ============================================================================
  // Factory methods for configurable icon sizes
  // ============================================================================

  static Widget warningIcon({double? size, Color? color}) => Icon(
    Icons.warning_amber_rounded,
    size: size,
    color: color ?? SigapColors.warning,
  );

  static Widget errorIcon({double? size, Color? color}) =>
      Icon(Icons.error_outline, size: size, color: color ?? SigapColors.danger);

  static Widget successIcon({double? size, Color? color}) => Icon(
    Icons.check_circle_outline,
    size: size,
    color: color ?? SigapColors.primary,
  );

  static Widget cameraIcon({double? size, Color? color}) =>
      Icon(Icons.add_a_photo, size: size, color: color ?? SigapColors.primary);

  static Widget locationIcon({double? size, Color? color}) =>
      Icon(Icons.location_on, size: size, color: color ?? SigapColors.primary);

  static Widget reportIcon({double? size, Color? color}) => Icon(
    Icons.description_outlined,
    size: size,
    color: color ?? SigapColors.textSecondary,
  );

  static Widget homeIcon({double? size, Color? color}) => Icon(
    Icons.home_outlined,
    size: size,
    color: color ?? SigapColors.textSecondary,
  );

  static Widget mapIcon({double? size, Color? color}) => Icon(
    Icons.map_outlined,
    size: size,
    color: color ?? SigapColors.textSecondary,
  );

  static Widget chevronRightIcon({double? size, Color? color}) => Icon(
    Icons.chevron_right,
    size: size,
    color: color ?? SigapColors.textSecondary,
  );

  static Widget categoryIcon({double? size, Color? color}) => Icon(
    Icons.category_outlined,
    size: size,
    color: color ?? SigapColors.textSecondary,
  );
}
