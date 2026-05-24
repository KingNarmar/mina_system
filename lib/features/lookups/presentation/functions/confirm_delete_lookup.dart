import 'package:flutter/material.dart';

void confirmDeleteLookup({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            child: const Text('Deactivate'),
          ),
        ],
      );
    },
  );
}
