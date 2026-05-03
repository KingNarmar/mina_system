import 'package:flutter/material.dart';

enum ReportType {
  workerCustody,
  toolHistory,
  transactions,
  lostDamaged,
  toolSummary,
}

class ReportOptionModel {
  const ReportOptionModel({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });

  final ReportType type;
  final String title;
  final String description;
  final IconData icon;
}
