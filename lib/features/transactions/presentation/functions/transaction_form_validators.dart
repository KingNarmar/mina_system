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

String? validateTransactionQuantity(
  String? value, {
  double? maxReturnQuantity,
}) {
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

  if (maxReturnQuantity != null && maxReturnQuantity <= 0) {
    return 'This worker does not have this tool in custody';
  }

  if (maxReturnQuantity != null && quantity > maxReturnQuantity) {
    return 'Quantity cannot exceed current balance';
  }

  return null;
}
