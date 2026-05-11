import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/widgets/main_button.dart';

class InviteCompanyUserForm extends StatelessWidget {
  const InviteCompanyUserForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.selectedRole,
    required this.allowedRoles,
    required this.isSubmitting,
    required this.onRoleChanged,
    required this.onInvitePressed,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final String selectedRole;
  final List<String> allowedRoles;
  final bool isSubmitting;
  final ValueChanged<String?> onRoleChanged;
  final VoidCallback onInvitePressed;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 700;

          final emailField = TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'User Email',
              border: OutlineInputBorder(),
            ),
            validator: _validateEmail,
          );

          final roleField = DropdownButtonFormField<String>(
            initialValue: selectedRole,
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
            ),
            items: allowedRoles.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(CompanyRoles.label(role)),
              );
            }).toList(),
            onChanged: isSubmitting ? null : onRoleChanged,
          );

          final inviteButton = SizedBox(
            width: isCompact ? double.infinity : 160,
            child: MainButton(
              text: 'Invite',
              isLoading: isSubmitting,
              onPressed: onInvitePressed,
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                emailField,
                const Gap(12),
                roleField,
                const Gap(12),
                inviteButton,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: emailField),
              const Gap(12),
              Expanded(child: roleField),
              const Gap(12),
              inviteButton,
            ],
          );
        },
      ),
    );
  }

  static String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final isValidEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!isValidEmail) {
      return 'Enter a valid email address';
    }

    return null;
  }
}
