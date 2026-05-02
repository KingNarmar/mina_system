String? validateRequiredTransactionText(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required';
  }

  return null;
}

String? validateRequiredTransactionDropdown(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please select a value';
  }

  return null;
}

String? validateRequiredTransactionSelection<T>(T? value) {
  if (value == null) {
    return 'Please select a value';
  }

  return null;
}

String? validateTransactionQuantity(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required';
  }

  final quantity = double.tryParse(value.trim());

  if (quantity == null) {
    return 'Please enter a valid number';
  }

  if (quantity <= 0) {
    return 'Quantity must be greater than zero';
  }

  return null;
}
