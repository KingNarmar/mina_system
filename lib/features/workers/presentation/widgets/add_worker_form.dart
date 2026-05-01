import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';

class AddWorkerForm extends StatelessWidget {
  const AddWorkerForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Worker', style: AppTextStyles.title),
            const SizedBox(height: 20),
            const CustomTextFormField(hint: 'Worker Name'),
            const SizedBox(height: 12),
            const CustomTextFormField(hint: 'HR Code'),
            const SizedBox(height: 12),
            const CustomTextFormField(hint: 'Department'),
            const SizedBox(height: 12),
            const CustomTextFormField(hint: 'Job Title'),
            const SizedBox(height: 20),
            MainButton(
              text: 'Save Worker',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
