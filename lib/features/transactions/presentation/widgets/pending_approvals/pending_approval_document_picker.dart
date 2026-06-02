part of 'pending_approval_actions.dart';

enum _ApprovalDocumentSource { camera, file }

bool get _canCaptureApprovalDocumentPhoto {
  if (kIsWeb) {
    return false;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => false,
  };
}

Future<String?> _selectApprovalDocumentPath(BuildContext context) async {
  if (!_canCaptureApprovalDocumentPhoto) {
    return _pickApprovalDocumentFile(context);
  }

  final selectedSource = await showModalBottomSheet<_ApprovalDocumentSource>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (bottomSheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ApprovalDocumentSourceTile(
                icon: AppIcons.photoCameraOutlined,
                title: 'Take Photo',
                subtitle: 'Capture the signed approval document.',
                onTap: () {
                  Navigator.of(
                    bottomSheetContext,
                  ).pop(_ApprovalDocumentSource.camera);
                },
              ),
              _ApprovalDocumentSourceTile(
                icon: AppIcons.attachFileRounded,
                title: 'Choose File',
                subtitle: 'Select a PDF, JPG, PNG, or WEBP file.',
                onTap: () {
                  Navigator.of(
                    bottomSheetContext,
                  ).pop(_ApprovalDocumentSource.file);
                },
              ),
            ],
          ),
        ),
      );
    },
  );

  if (!context.mounted || selectedSource == null) {
    return null;
  }

  return switch (selectedSource) {
    _ApprovalDocumentSource.camera => _takeApprovalDocumentPhoto(context),
    _ApprovalDocumentSource.file => _pickApprovalDocumentFile(context),
  };
}

Future<String?> _takeApprovalDocumentPhoto(BuildContext context) async {
  try {
    final photo = await ImagePicker().pickImage(source: ImageSource.camera);

    return photo?.path;
  } catch (_) {
    if (!context.mounted) {
      return null;
    }

    AppMessage.showError(
      context,
      'Could not open the camera. Please choose a file instead.',
    );

    return null;
  }
}

Future<String?> _pickApprovalDocumentFile(BuildContext context) async {
  try {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    return result.files.single.path;
  } catch (_) {
    if (!context.mounted) {
      return null;
    }

    AppMessage.showError(
      context,
      'Could not choose the approval document. Please try again.',
    );

    return null;
  }
}

class _ApprovalDocumentSourceTile extends StatelessWidget {
  const _ApprovalDocumentSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
