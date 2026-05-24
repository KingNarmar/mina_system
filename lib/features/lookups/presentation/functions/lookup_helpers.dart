String normalizeText(String value) {
  return value.trim().toLowerCase().replaceAll(
    RegExp(r'[^\p{L}\p{N}]+', unicode: true),
    '',
  );
}

bool isSameValue(String firstValue, String secondValue) {
  return normalizeText(firstValue) == normalizeText(secondValue);
}

bool containsValue(List<String> values, String value) {
  return values.any((item) => isSameValue(item, value));
}
