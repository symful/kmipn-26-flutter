import 'package:flutter/widgets.dart';
import 'generated/app_localizations.dart';

/// Localize the configured baseline categories; custom operator names stay intact.
String categoryLabel(BuildContext context, String name) {
  final l10n = AppLocalizations.of(context)!;
  return switch (name.trim().toLowerCase()) {
    'jalan' || 'jalan rusak' || 'road' => l10n.categoryRoad,
    'jembatan' => l10n.categoryBridge,
    'air bersih' || 'air_bersih' || 'clean_water' => l10n.categoryCleanWater,
    'fasilitas umum' => l10n.categoryPublicFacility,
    'irigasi' => l10n.categoryIrrigation,
    'unknown' || '' => l10n.categoryUnknown,
    _ => name,
  };
}
