import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_form_validators.dart';
import 'package:mina_system/features/transactions/presentation/widgets/form/transaction_image_picker_field.dart';

class TransactionDetailsSection extends StatelessWidget {
  const TransactionDetailsSection({
    super.key,
    required this.quantityController,
    required this.noteController,
    required this.selectedImagePath,
    required this.isProofImageRequired,
    required this.isNoteRequired,
    required this.maxReturnQuantity,
    required this.onImageSelected,
  });

  final TextEditingController quantityController;
  final TextEditingController noteController;
  final String? selectedImagePath;
  final bool isProofImageRequired;
  final bool isNoteRequired;
  final double? maxReturnQuantity;
  final ValueChanged<String?> onImageSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormField(
          hint: 'Quantity',
          controller: quantityController,
          keyboardType: TextInputType.number,
          validator: (value) {
            return validateTransactionQuantity(
              value,
              maxReturnQuantity: maxReturnQuantity,
            );
          },
        ),
        const Gap(12),
        TransactionImagePickerField(
          imagePath: selectedImagePath,
          isRequired: isProofImageRequired,
          onImageSelected: onImageSelected,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: isNoteRequired ? 'Note *' : 'Note (optional)',
          controller: noteController,
          validator: (value) {
            if (!isNoteRequired) {
              return null;
            }

            if (value == null || value.trim().isEmpty) {
              return 'Note is required for lost or damaged transactions';
            }

            return null;
          },
        ),
      ],
    );
  }
}
