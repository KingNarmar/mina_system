import 'package:flutter/material.dart';

class ReportOptionModel {
  const ReportOptionModel({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}