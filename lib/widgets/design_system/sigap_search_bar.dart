import 'package:sigap/theme/sigap_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Global search bar matching the Sigap_Front-End golden standard.
///
/// Design spec (style.css .topbar input):
/// - Width: 310px (max-width on mobile, flexible on wider screens)
/// - Background: #f4f5f3 ([SigapColorScheme.of(context).bgSurface])
/// - Border-radius: 8px ([SigapRadius.x8])
/// - Font: IBM Plex Sans 12px ([SigapTypography.bodySmall])
/// - Placeholder: "Cari kasus, desa, atau unit..."
/// - Search icon prefix
///
/// Usage:
/// ```dart
/// SigapAppBar(
///   title: 'Dashboard',
///   searchBar: SigapSearchBar(),
/// )
/// ```
class SigapSearchBar extends StatelessWidget {
  /// Controller for the text field. Caller manages state.
  final TextEditingController? controller;

  /// Callback when the user submits a search query.
  final ValueChanged<String>? onSubmitted;

  /// Callback when the text changes (for live search).
  final ValueChanged<String>? onChanged;

  /// Placeholder text. Defaults to "Cari kasus, desa, atau unit...".
  final String? hintText;

  /// Maximum width of the search bar. Defaults to 310.
  final double maxWidth;

  const SigapSearchBar({
    super.key,
    this.controller,
    this.onSubmitted,
    this.onChanged,
    this.hintText,
    this.maxWidth = 310,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SizedBox(
        height: 36,
        child: TextField(
          controller: controller,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: SigapTypography.bodySmall,
            fontFamily: SigapTypography.fontFamilySans,
            color: SigapColorScheme.of(context).textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? 'Cari kasus, desa, atau unit...',
            hintStyle: TextStyle(
              fontSize: SigapTypography.bodySmall,
              fontFamily: SigapTypography.fontFamilySans,
              color: SigapColorScheme.of(context).textMuted,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 18,
              color: SigapColorScheme.of(context).textMuted,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 0,
            ),
            filled: true,
            fillColor: SigapColorScheme.of(context).bgSurface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SigapSpacing.sm,
              vertical: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SigapRadius.x8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SigapRadius.x8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SigapRadius.x8),
              borderSide: BorderSide(color: SigapColors.primary, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
