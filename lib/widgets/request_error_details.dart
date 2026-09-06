import 'package:flutter/material.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';

void showRequestFailure(BuildContext context, Object error, {String? message}) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message ?? l10n.mobileRetryRequestExplanation),
      action: SnackBarAction(
        label: l10n.detail,
        onPressed: () => showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.mobileTechnicalDetails),
            content: SingleChildScrollView(
              child: SelectableText(error.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.tutup),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Keep implementation errors available without making them the main message.
class RequestErrorDetails extends StatelessWidget {
  const RequestErrorDetails({super.key, required this.details, this.message});
  final String details;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message ?? l10n.mobileRequestFailedExplanation),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(l10n.mobileTechnicalDetails),
          children: [SelectableText(details)],
        ),
      ],
    );
  }
}
