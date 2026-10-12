import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum Severity { high, medium, low }

extension SeverityStyle on Severity {
  Color get color {
    switch (this) {
      case Severity.high:
        return AppColors.danger;
      case Severity.medium:
        return AppColors.warning;
      case Severity.low:
        return AppColors.success;
    }
  }

  String get label {
    switch (this) {
      case Severity.high:
        return 'High risk';
      case Severity.medium:
        return 'Medium risk';
      case Severity.low:
        return 'Low risk';
    }
  }
}

class Violation {
  final String title;
  final String description;
  final Severity severity;

  const Violation({
    required this.title,
    required this.description,
    required this.severity,
  });
}
