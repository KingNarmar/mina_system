import 'package:flutter/material.dart';
import 'package:mina_system/core/utils/app_timezones.dart';

class CompanyProfileFormHelpers {
  static String? validateCompanyName(String? value) {
    final companyName = value?.trim() ?? '';

    if (companyName.isEmpty) {
      return 'Company name is required';
    }

    if (companyName.length < 2) {
      return 'Company name is too short';
    }

    return null;
  }

  static String? validateTimezone(String? value) {
    final timezone = value?.trim() ?? '';

    if (timezone.isEmpty) {
      return 'Company timezone is required';
    }

    if (!AppTimezones.isValidTimezone(timezone)) {
      return 'Select a valid company timezone';
    }

    return null;
  }

  static String? validateOptionalEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return null;
    }

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
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
