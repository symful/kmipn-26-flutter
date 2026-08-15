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
    color: AppColors.warning,
  );

  static const Icon warningOutlined = Icon(
    Icons.warning_amber_outlined,
    color: AppColors.warning,
  );

  static const Icon error = Icon(Icons.error_outline, color: AppColors.danger);

  static const Icon errorFilled = Icon(Icons.error, color: AppColors.danger);

  static const Icon success = Icon(
    Icons.check_circle_outline,
    color: AppColors.primary,
  );

  static const Icon successFilled = Icon(
    Icons.check_circle,
    color: AppColors.primary,
  );

  static const Icon info = Icon(Icons.info_outline, color: AppColors.info);

  static const Icon infoFilled = Icon(Icons.info, color: AppColors.info);

  // ============================================================================
  // Navigation Icons
  // ============================================================================

  static const Icon chevronRight = Icon(
    Icons.chevron_right,
    color: AppColors.textSecondary,
  );

  static const Icon chevronLeft = Icon(
    Icons.chevron_left,
    color: AppColors.textSecondary,
  );

  static const Icon arrowBack = Icon(
    Icons.arrow_back,
    color: AppColors.textPrimary,
  );

  static const Icon home = Icon(
    Icons.home_outlined,
    color: AppColors.textSecondary,
  );

  static const Icon homeFilled = Icon(Icons.home, color: AppColors.primary);

  // ============================================================================
  // Action Icons
  // ============================================================================

  static const Icon camera = Icon(Icons.add_a_photo, color: AppColors.primary);

  static const Icon cameraOutlined = Icon(
    Icons.add_a_photo_outlined,
    color: AppColors.textSecondary,
  );

  static const Icon location = Icon(
    Icons.location_on,
    color: AppColors.primary,
  );

  static const Icon locationOutlined = Icon(
    Icons.location_on_outlined,
    color: AppColors.textSecondary,
  );

  static const Icon report = Icon(
    Icons.description_outlined,
    color: AppColors.textSecondary,
  );

  static const Icon reportFilled = Icon(
    Icons.description,
    color: AppColors.primary,
  );

  static const Icon add = Icon(Icons.add, color: AppColors.primary);

  static const Icon edit = Icon(
    Icons.edit_outlined,
    color: AppColors.textSecondary,
  );

  static const Icon delete = Icon(
    Icons.delete_outline,
    color: AppColors.danger,
  );

  static const Icon refresh = Icon(
    Icons.refresh,
    color: AppColors.textSecondary,
  );

  static const Icon sync = Icon(Icons.sync, color: AppColors.primary);

  // ============================================================================
  // Map & Location Icons
  // ============================================================================

  static const Icon map = Icon(
    Icons.map_outlined,
    color: AppColors.textSecondary,
  );

  static const Icon mapFilled = Icon(Icons.map, color: AppColors.primary);

  static const Icon myLocation = Icon(
    Icons.my_location,
    color: AppColors.primary,
  );

  // ============================================================================
  // List & Queue Icons
  // ============================================================================

  static const Icon list = Icon(Icons.list, color: AppColors.textSecondary);

  static const Icon inbox = Icon(Icons.inbox, color: AppColors.textSecondary);

  static const Icon inboxOutlined = Icon(
    Icons.inbox_outlined,
    color: AppColors.textSecondary,
  );

  static const Icon queue = Icon(Icons.queue, color: AppColors.primary);

  // ============================================================================
  // Category & Tag Icons
  // ============================================================================

  static const Icon category = Icon(
    Icons.category_outlined,
    color: AppColors.textSecondary,
  );

  static const Icon categoryFilled = Icon(
    Icons.category,
    color: AppColors.primary,
  );

  static const Icon tag = Icon(Icons.tag, color: AppColors.textSecondary);

  // ============================================================================
  // User & Role Icons
  // ============================================================================

  static const Icon person = Icon(
    Icons.person_outline,
    color: AppColors.textSecondary,
  );

  static const Icon personFilled = Icon(Icons.person, color: AppColors.primary);

  static const Icon verified = Icon(
    Icons.verified_outlined,
    color: AppColors.primary,
  );

  static const Icon verifiedFilled = Icon(
    Icons.verified,
    color: AppColors.primary,
  );

  static const Icon people = Icon(
    Icons.people_outline,
    color: AppColors.textSecondary,
  );

  // ============================================================================
  // Communication Icons
  // ============================================================================

  static const Icon email = Icon(
    Icons.email_outlined,
    color: AppColors.textSecondary,
  );

  static const Icon lock = Icon(
    Icons.lock_outlined,
    color: AppColors.textSecondary,
  );

  static const Icon visibility = Icon(
    Icons.visibility_outlined,
    color: AppColors.textSecondary,
  );

  static const Icon visibilityOff = Icon(
    Icons.visibility_off_outlined,
    color: AppColors.textSecondary,
  );

  // ============================================================================
  // Status Indicator Icons (for ListTiles, Cards, etc.)
  // ============================================================================

  static const Icon perluTindakan = Icon(
    Icons.pending_actions,
    color: AppColors.danger,
  );

  static const Icon diproses = Icon(
    Icons.pending_outlined,
    color: AppColors.info,
  );

  static const Icon selesai = Icon(
    Icons.check_circle_outline,
    color: AppColors.primary,
  );

  static const Icon timer = Icon(
    Icons.timer_outlined,
    color: AppColors.textSecondary,
  );

  // ============================================================================
  // Factory methods for configurable icon sizes
  // ============================================================================

  static Widget warningIcon({double? size, Color? color}) => Icon(
    Icons.warning_amber_rounded,
    size: size,
    color: color ?? AppColors.warning,
  );

  static Widget errorIcon({double? size, Color? color}) =>
      Icon(Icons.error_outline, size: size, color: color ?? AppColors.danger);

  static Widget successIcon({double? size, Color? color}) => Icon(
    Icons.check_circle_outline,
    size: size,
    color: color ?? AppColors.primary,
  );

  static Widget cameraIcon({double? size, Color? color}) =>
      Icon(Icons.add_a_photo, size: size, color: color ?? AppColors.primary);

  static Widget locationIcon({double? size, Color? color}) =>
      Icon(Icons.location_on, size: size, color: color ?? AppColors.primary);

  static Widget reportIcon({double? size, Color? color}) => Icon(
    Icons.description_outlined,
    size: size,
    color: color ?? AppColors.textSecondary,
  );

  static Widget homeIcon({double? size, Color? color}) => Icon(
    Icons.home_outlined,
    size: size,
    color: color ?? AppColors.textSecondary,
  );

  static Widget mapIcon({double? size, Color? color}) => Icon(
    Icons.map_outlined,
    size: size,
    color: color ?? AppColors.textSecondary,
  );

  static Widget chevronRightIcon({double? size, Color? color}) => Icon(
    Icons.chevron_right,
    size: size,
    color: color ?? AppColors.textSecondary,
  );

  static Widget categoryIcon({double? size, Color? color}) => Icon(
    Icons.category_outlined,
    size: size,
    color: color ?? AppColors.textSecondary,
  );
}
