import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:signature/signature.dart';
import 'package:mina_system/core/theme/app_icons.dart';

Future<Uint8List?> showSignatureCaptureDialog(BuildContext context) {
  return showDialog<Uint8List?>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const SignatureCaptureDialog(),
  );
}

class SignatureCaptureDialog extends StatefulWidget {
  const SignatureCaptureDialog({super.key});

  @override
  State<SignatureCaptureDialog> createState() => _SignatureCaptureDialogState();
}

class _SignatureCaptureDialogState extends State<SignatureCaptureDialog> {
  late final SignatureController _signatureController;

  bool _isExporting = false;

  @override
  void initState() {
    super.initState();

    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final isCompact = mediaSize.width < 700;

    return Dialog(
      insetPadding: EdgeInsets.all(isCompact ? 16 : 24),
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: mediaSize.height * 0.9,
        ),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 16 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const Gap(16),
              const Text(
                'Ask the worker to sign inside the box below. On mobile/tablet use touch or stylus. On desktop use the connected signature pad / pen tablet.',
                style: AppTextStyles.body,
              ),
              const Gap(16),
              _buildSignatureCanvas(isCompact: isCompact),
              const Gap(12),
              const Text(
                'This signature will be embedded into the final signed PDF.',
                style: AppTextStyles.caption,
              ),
              const Gap(20),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(AppIcons.drawOutlined, color: AppColors.accent),
        ),
        const Gap(12),
        const Expanded(
          child: Text('Capture Signature', style: AppTextStyles.title),
        ),
        IconButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          icon: const Icon(AppIcons.close),
        ),
      ],
    );
  }

  Widget _buildSignatureCanvas({required bool isCompact}) {
    return Container(
      height: isCompact ? 260 : 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Signature(
        controller: _signatureController,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isExporting ? null : _signatureController.clear,
            icon: const Icon(AppIcons.refreshOutlined),
            label: const Text('Clear'),
          ),
        ),
        const Gap(12),
        Expanded(
          child: OutlinedButton(
            onPressed: _isExporting ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        const Gap(12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isExporting ? null : _confirmSignature,
            icon: _isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(AppIcons.approve),
            label: Text(_isExporting ? 'Saving...' : 'Use Signature'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSignature() async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please capture the worker signature first.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final signatureBytes = await _signatureController.toPngBytes();

      if (!mounted) {
        return;
      }

      if (signatureBytes == null || signatureBytes.isEmpty) {
        throw StateError('Signature image could not be exported.');
      }

      Navigator.pop(context, signatureBytes);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isExporting = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Unable to export the signature. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}
