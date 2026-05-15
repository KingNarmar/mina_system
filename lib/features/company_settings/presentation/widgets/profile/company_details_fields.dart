import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/searchable_timezone_form_field.dart';

import 'company_profile_form_helpers.dart';

class CompanyDetailsFields extends StatelessWidget {
  const CompanyDetailsFields({
    super.key,
    required this.controllers,
    required this.selectedTimezone,
    required this.onTimezoneChanged,
  });

  final CompanyProfileControllers controllers;
  final String selectedTimezone;
  final void Function(String timezone) onTimezoneChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CompanyProfileFieldsSection(
          title: 'Basic Details',
          description: 'Official company identity used across the system.',
          children: [
            _CompanyProfileTextField(
              hint: 'Company Name',
              controller: controllers.nameController,
              keyboardType: TextInputType.name,
              validator: CompanyProfileFormHelpers.validateCompanyName,
            ),
            _CompanyProfileTextField(
              hint: 'Trade Name',
              controller: controllers.tradeNameController,
              keyboardType: TextInputType.name,
            ),
            _CompanyProfileTextField(
              hint: 'Legal Name',
              controller: controllers.legalNameController,
              keyboardType: TextInputType.name,
            ),
            _CompanyProfileTimezoneField(
              selectedTimezone: selectedTimezone,
              onTimezoneChanged: onTimezoneChanged,
            ),
          ],
        ),
        const Gap(18),
        _CompanyProfileFieldsSection(
          title: 'Compliance',
          description: 'Registration and tax references for company records.',
          children: [
            _CompanyProfileTextField(
              hint: 'Trade License No.',
              controller: controllers.tradeLicenseNoController,
            ),
            _CompanyProfileTextField(
              hint: 'Tax Registration No.',
              controller: controllers.taxRegistrationNoController,
            ),
          ],
        ),
        const Gap(18),
        _CompanyProfileFieldsSection(
          title: 'Address',
          description: 'Company address details displayed in future documents.',
          children: [
            _CompanyProfileTextField(
              hint: 'Address Line 1',
              controller: controllers.addressLine1Controller,
              keyboardType: TextInputType.streetAddress,
            ),
            _CompanyProfileTextField(
              hint: 'Address Line 2',
              controller: controllers.addressLine2Controller,
              keyboardType: TextInputType.streetAddress,
            ),
            _CompanyProfileTextField(
              hint: 'City',
              controller: controllers.cityController,
            ),
            _CompanyProfileTextField(
              hint: 'Country',
              controller: controllers.countryController,
            ),
          ],
        ),
        const Gap(18),
        _CompanyProfileFieldsSection(
          title: 'Contact',
          description: 'Public contact details for reports and documents.',
          children: [
            _CompanyProfileTextField(
              hint: 'Phone',
              controller: controllers.phoneController,
              keyboardType: TextInputType.phone,
            ),
            _CompanyProfileTextField(
              hint: 'Email',
              controller: controllers.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: CompanyProfileFormHelpers.validateOptionalEmail,
            ),
            _CompanyProfileTextField(
              hint: 'Website',
              controller: controllers.websiteController,
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ],
    );
  }
}

class _CompanyProfileFieldsSection extends StatelessWidget {
  const _CompanyProfileFieldsSection({
    required this.title,
    required this.description,
    required this.children,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompanyProfileSectionHeader(title: title, description: description),
          const Gap(14),
          _CompanyProfileFieldGrid(children: children),
        ],
      ),
    );
  }
}

class _CompanyProfileSectionHeader extends StatelessWidget {
  const _CompanyProfileSectionHeader({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(3),
              Text(
                description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompanyProfileFieldGrid extends StatelessWidget {
  const _CompanyProfileFieldGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final isTwoColumns = constraints.maxWidth >= 720;
        final fieldWidth = isTwoColumns
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((child) {
            return SizedBox(width: fieldWidth, child: child);
          }).toList(),
        );
      },
    );
  }
}

class _CompanyProfileTextField extends StatelessWidget {
  const _CompanyProfileTextField({
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      hint: hint,
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      fillColor: AppColors.card,
      borderColor: AppColors.border,
      focusedBorderColor: AppColors.accent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      textStyle: AppTextStyles.body.copyWith(
        color: AppColors.textPrimary,
        fontSize: 14,
        height: 1.25,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _CompanyProfileTimezoneField extends StatelessWidget {
  const _CompanyProfileTimezoneField({
    required this.selectedTimezone,
    required this.onTimezoneChanged,
  });

  final String selectedTimezone;
  final void Function(String timezone) onTimezoneChanged;

  @override
  Widget build(BuildContext context) {
    return SearchableTimezoneFormField(
      value: selectedTimezone,
      helperText:
          'Used to display audit logs, transactions, and reports in your company local time.',
      validator: CompanyProfileFormHelpers.validateTimezone,
      onChanged: onTimezoneChanged,
      fillColor: AppColors.card,
      borderColor: AppColors.border,
      focusedBorderColor: AppColors.accent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      textStyle: AppTextStyles.body.copyWith(
        color: AppColors.textPrimary,
        fontSize: 14,
        height: 1.25,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
