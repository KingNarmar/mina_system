import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'company_profile_form_helpers.dart';

class CompanyDetailsFields extends StatelessWidget {
  const CompanyDetailsFields({super.key, required this.controllers});

  final CompanyProfileControllers controllers;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormField(
          hint: 'Company Name',
          controller: controllers.nameController,
          keyboardType: TextInputType.name,
          validator: CompanyProfileFormHelpers.validateRequired,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Trade Name',
          controller: controllers.tradeNameController,
          keyboardType: TextInputType.name,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Legal Name',
          controller: controllers.legalNameController,
          keyboardType: TextInputType.name,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Trade License No.',
          controller: controllers.tradeLicenseNoController,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Tax Registration No.',
          controller: controllers.taxRegistrationNoController,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Address Line 1',
          controller: controllers.addressLine1Controller,
          keyboardType: TextInputType.streetAddress,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Address Line 2',
          controller: controllers.addressLine2Controller,
          keyboardType: TextInputType.streetAddress,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'City',
          controller: controllers.cityController,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Country',
          controller: controllers.countryController,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Phone',
          controller: controllers.phoneController,
          keyboardType: TextInputType.phone,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Email',
          controller: controllers.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const Gap(12),
        CustomTextFormField(
          hint: 'Website',
          controller: controllers.websiteController,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
}
