String formatQuantity(double quantity) {
  if (quantity % 1 == 0) {
    return quantity.toInt().toString();
  }

  return quantity.toString();
}
