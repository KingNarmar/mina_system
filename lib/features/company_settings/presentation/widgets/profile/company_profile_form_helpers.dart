import 'package:flutter/material.dart';

class CompanyProfileFormHelpers {
  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Company name is required';
    }
    return null;
  }
}

class CompanyProfileControllers {
  final TextEditingController nameController;
  final TextEditingController tradeNameController;
  final TextEditingController legalNameController;
  final TextEditingController tradeLicenseNoController;
  final TextEditingController taxRegistrationNoController;
  final TextEditingController addressLine1Controller;
  final TextEditingController addressLine2Controller;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController websiteController;

  CompanyProfileControllers({
    required this.nameController,
    required this.tradeNameController,
    required this.legalNameController,
    required this.tradeLicenseNoController,
    required this.taxRegistrationNoController,
    required this.addressLine1Controller,
    required this.addressLine2Controller,
    required this.cityController,
    required this.countryController,
    required this.phoneController,
    required this.emailController,
    required this.websiteController,
  });

  void dispose() {
    nameController.dispose();
    tradeNameController.dispose();
    legalNameController.dispose();
    tradeLicenseNoController.dispose();
    taxRegistrationNoController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    countryController.dispose();
    phoneController.dispose();
    emailController.dispose();
    websiteController.dispose();
  }
}
