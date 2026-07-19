enum TransactionImageReferenceKind {
  empty,
  secureRemoteUrl,
  insecureRemoteUrl,
  unsupportedRemoteUrl,
  path,
}

class TransactionImageReference {
  const TransactionImageReference({required this.kind, required this.value});

  final TransactionImageReferenceKind kind;
  final String value;

  bool get isSecureRemoteUrl =>
      kind == TransactionImageReferenceKind.secureRemoteUrl;

  bool get isRejectedRemoteUrl =>
      kind == TransactionImageReferenceKind.insecureRemoteUrl ||
      kind == TransactionImageReferenceKind.unsupportedRemoteUrl;
}

TransactionImageReference classifyTransactionImageReference(String rawValue) {
  final value = rawValue.trim();

  if (value.isEmpty) {
    return const TransactionImageReference(
      kind: TransactionImageReferenceKind.empty,
      value: '',
    );
  }

  if (_looksLikeWindowsDrivePath(value)) {
    return TransactionImageReference(
      kind: TransactionImageReferenceKind.path,
      value: value,
    );
  }

  final uri = Uri.tryParse(value);
  final scheme = uri?.scheme.toLowerCase() ?? '';

  if (scheme == 'https') {
    final hasValidAuthority =
        uri != null && uri.hasAuthority && uri.host.trim().isNotEmpty;

    return TransactionImageReference(
      kind: hasValidAuthority
          ? TransactionImageReferenceKind.secureRemoteUrl
          : TransactionImageReferenceKind.unsupportedRemoteUrl,
      value: value,
    );
  }

  if (scheme == 'http') {
    return TransactionImageReference(
      kind: TransactionImageReferenceKind.insecureRemoteUrl,
      value: value,
    );
  }

  if (scheme.isNotEmpty) {
    return TransactionImageReference(
      kind: TransactionImageReferenceKind.unsupportedRemoteUrl,
      value: value,
    );
  }

  return TransactionImageReference(
    kind: TransactionImageReferenceKind.path,
    value: value,
  );
}

bool _looksLikeWindowsDrivePath(String value) {
  if (value.length < 3) {
    return false;
  }

  final driveLetterCode = value.codeUnitAt(0);
  final isAsciiLetter =
      (driveLetterCode >= 65 && driveLetterCode <= 90) ||
      (driveLetterCode >= 97 && driveLetterCode <= 122);

  if (!isAsciiLetter || value[1] != ':') {
    return false;
  }

  final separatorCode = value.codeUnitAt(2);

  return separatorCode == 92 || separatorCode == 47;
}
