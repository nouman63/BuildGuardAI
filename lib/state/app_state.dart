import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/violation.dart';

/// Holds session + project data in memory.
///
/// This stands in for the real backend (REST API / Firestore, per the
/// report's software requirements) so the UI is fully navigable and
/// demoable before the integration is wired up. Swap the bodies of these
/// methods for real API/Firestore calls when the backend is ready.
class AppState extends ChangeNotifier {
  String? userName;
  String? userEmail;
  bool get isLoggedIn => userEmail != null;

  final List<Project> projects = [
    Project(
      id: 'p1',
      name: 'New Office Building',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      numberOfWorkers: 24,
      percentComplete: 62,
      remainingTasks: 'Electrical wiring, drywall finishing',
      riskLevel: RiskLevel.high,
      violations: const [
        Violation(
          title: 'Improper Column Spacing',
          description: 'Columns are placed too close; structural integrity at risk.',
          severity: Severity.high,
        ),
        Violation(
          title: 'Missing Support Structures',
          description: 'Critical support beams absent in designated area.',
          severity: Severity.high,
        ),
        Violation(
          title: 'Structural Misalignment',
          description: 'Supporting columns are misaligned with beams.',
          severity: Severity.medium,
        ),
      ],
      riskSummary:
          'High likelihood of schedule delay due to structural rework and current workforce level.',
    ),
    Project(
      id: 'p2',
      name: 'Riverside Residency – Block C',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      numberOfWorkers: 12,
      percentComplete: 88,
      remainingTasks: 'Painting, fixtures',
      riskLevel: RiskLevel.low,
      violations: const [
        Violation(
          title: 'Minor Door Clearance Issue',
          description: 'One doorway is slightly under the recommended clearance width.',
          severity: Severity.low,
        ),
      ],
      riskSummary: 'Low risk. Project is on track to finish within schedule.',
    ),
    Project(
      id: 'p3',
      name: 'Al-Habib Plaza Renovation',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      numberOfWorkers: 8,
      percentComplete: 35,
      remainingTasks: 'Framing, MEP rough-in, inspection',
      riskLevel: RiskLevel.medium,
      violations: const [
        Violation(
          title: 'Staircase Width Violation',
          description: 'Staircase width is below the minimum simplified safety guideline.',
          severity: Severity.medium,
        ),
        Violation(
          title: 'Window Egress Concern',
          description: 'Bedroom window opening may not meet emergency egress size.',
          severity: Severity.medium,
        ),
      ],
      riskSummary:
          'Moderate risk driven by low current workforce relative to remaining scope.',
    ),
  ];

  void login(String email) {
    userEmail = email;
    userName ??= email.split('@').first;
    notifyListeners();
  }

  void signUp(String fullName, String email) {
    userName = fullName;
    userEmail = email;
    notifyListeners();
  }

  void logout() {
    userEmail = null;
    notifyListeners();
  }

  Project createProject(String name) {
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    projects.insert(0, project);
    notifyListeners();
    return project;
  }

  void updateProjectData({
    required String projectId,
    required int workers,
    required double percentComplete,
    required String remainingTasks,
  }) {
    final project = projects.firstWhere((p) => p.id == projectId);
    project.numberOfWorkers = workers;
    project.percentComplete = percentComplete;
    project.remainingTasks = remainingTasks;
    notifyListeners();
  }

  /// Mocks the computer-vision + ML analysis pipeline described in the
  /// report (structural detection, rule comparison, risk prediction).
  void completeAnalysis(String projectId) {
    final project = projects.firstWhere((p) => p.id == projectId);
    final workers = project.numberOfWorkers ?? 10;
    final progress = project.percentComplete ?? 50;

    project.violations = const [
      Violation(
        title: 'Improper Column Spacing',
        description: 'Columns are placed too close; structural integrity at risk.',
        severity: Severity.high,
      ),
      Violation(
        title: 'Missing Support Structures',
        description: 'Critical support beams absent in designated area.',
        severity: Severity.high,
      ),
      Violation(
        title: 'Structural Misalignment',
        description: 'Supporting columns are misaligned with beams.',
        severity: Severity.medium,
      ),
    ];

    final riskScore = (100 - progress) / 10 + (workers < 10 ? 3 : 0);
    project.riskLevel = riskScore > 8
        ? RiskLevel.high
        : riskScore > 4
            ? RiskLevel.medium
            : RiskLevel.low;
    project.riskSummary = project.riskLevel == RiskLevel.high
        ? 'High likelihood of schedule delay given current workforce and remaining scope.'
        : project.riskLevel == RiskLevel.medium
            ? 'Moderate risk — monitor workforce allocation over the next phase.'
            : 'Low risk. Project is progressing within safe parameters.';

    notifyListeners();
  }
}
