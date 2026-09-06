import 'package:flutter/material.dart';

IconData facilityIcon({String? slug, String? name}) {
  final identity = (slug?.isNotEmpty == true ? slug! : name ?? '')
      .toLowerCase();
  if (identity.contains('jembatan') || identity.contains('bridge')) {
    return Icons.account_balance_outlined;
  }
  if (identity.contains('penerangan') || identity.contains('lighting')) {
    return Icons.lightbulb_outline;
  }
  if (identity.contains('drain') || identity.contains('irigasi')) {
    return Icons.water_outlined;
  }
  if (identity.contains('air') || identity.contains('water')) {
    return Icons.water_drop_outlined;
  }
  if (identity.contains('jalan') || identity.contains('road')) {
    return Icons.add_road;
  }
  return Icons.location_city_outlined;
}
