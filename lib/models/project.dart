import 'violation.dart';

enum RiskLevel { high, medium, low, pending }

class Project {
  final String id;
  final String name;
  final DateTime createdAt;
  String? floorPlanPath;
  int? numberOfWorkers;
  double? percentComplete;
  String? remainingTasks;
  RiskLevel riskLevel;
  List<Violation> violations;
  String? riskSummary;

  Project({
    required this.id,
    required this.name,
    required this.createdAt,
    this.floorPlanPath,
    this.numberOfWorkers,
    this.percentComplete,
    this.remainingTasks,
    this.riskLevel = RiskLevel.pending,
    List<Violation>? violations,
    this.riskSummary,
  }) : violations = violations ?? [];
}
