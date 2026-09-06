/// SQLite timestamps from the API are UTC even when the offset is omitted.
DateTime? parseServerTimestamp(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final text = value.trim();
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
    return DateTime.tryParse(text);
  }
  final hasOffset = RegExp(
    r'(Z|[+-]\d{2}:?\d{2})$',
    caseSensitive: false,
  ).hasMatch(text);
  return DateTime.tryParse(
    hasOffset ? text : '${text.replaceFirst(' ', 'T')}Z',
  );
}
