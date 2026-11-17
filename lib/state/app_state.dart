import 'dart:async';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/violation.dart';
import '../models/risk_assessment.dart';
import '../services/app_backend.dart';
import '../services/firebase_backend.dart';

class AppState extends ChangeNotifier {
  final AppBackend? backend;
  AppState({this.backend}) {
    authReady = backend == null;
    _authSubscription =
        backend?.sessions.listen(_sessionChanged, onError: (Object error) {
      authReady = true;
      syncError = friendlyError(error);
      notifyListeners();
    });
  }
  AuthSession? session;
  String? get userName => session?.name ?? session?.email?.split('@').first;
  String? get userEmail => session?.email;
  bool get isLoggedIn => session != null;
  bool authReady = false;
  bool reportsLoading = false;
  String? syncError;
  final List<RiskAssessment> riskReports = [];
  final List<Project> projects = [];
  final Set<String> _draftIds = {};
  StreamSubscription<AuthSession?>? _authSubscription;
  StreamSubscription<List<RiskAssessment>>? _riskSubscription;
  StreamSubscription<List<Project>>? _projectSubscription;
  int _generation = 0;

  void _sessionChanged(AuthSession? next) {
    final changed = session?.uid != next?.uid;
    session = next;
    authReady = true;
    if (changed) {
      _generation++;
      _riskSubscription?.cancel();
      _projectSubscription?.cancel();
      riskReports.clear();
      projects.clear();
      _draftIds.clear();
      syncError = null;
      if (next != null) {
        _subscribe(next.uid);
      } else {
        reportsLoading = false;
      }
    }
    notifyListeners();
  }

  void _subscribe(String uid) {
    final generation = _generation;
    reportsLoading = true;
    var riskReceived = false, projectsReceived = false;
    void received() {
      reportsLoading = !riskReceived || !projectsReceived;
    }

    void failed(Object error) {
      if (generation != _generation) return;
      syncError = friendlyError(error);
      reportsLoading = false;
      notifyListeners();
    }

    _riskSubscription = backend!.watchRiskReports(uid).listen((reports) {
      if (generation != _generation) return;
      riskReports
        ..clear()
        ..addAll(reports);
      riskReceived = true;
      received();
      notifyListeners();
    }, onError: failed);
    _projectSubscription = backend!.watchProjects(uid).listen((reports) {
      if (generation != _generation) return;
      final local = {for (final p in projects) p.id: p};
      final drafts = projects
          .where((p) =>
              _draftIds.contains(p.id) && !reports.any((r) => r.id == p.id))
          .toList();
      for (final report in reports) {
        report.floorPlanPath = local[report.id]?.floorPlanPath;
      }
      projects
        ..clear()
        ..addAll([...drafts, ...reports]);
      projectsReceived = true;
      received();
      notifyListeners();
    }, onError: failed);
  }

  void retryReports() {
    if (backend == null || session == null) return;
    _generation++;
    _riskSubscription?.cancel();
    _projectSubscription?.cancel();
    syncError = null;
    _subscribe(session!.uid);
    notifyListeners();
  }

  AppBackend get _requiredBackend =>
      backend ??
      (throw const AppFailure('Configure Firebase before signing in.'));
  Future<void> login(String email, String password) =>
      _requiredBackend.login(email, password);
  Future<void> signUp(String fullName, String email, String password) =>
      _requiredBackend.signUp(fullName, email, password);
  Future<void> resetPassword(String email) =>
      _requiredBackend.resetPassword(email);
  Future<void> logout() async {
    await _requiredBackend.logout();
    _sessionChanged(null);
  }

  Future<void> saveRiskReport(RiskAssessment report) async {
    if (backend == null) {
      riskReports.insert(0, report);
      notifyListeners();
      return;
    }
    final uid = session?.uid;
    if (uid == null) throw const AppFailure('Sign in to save reports.');
    await backend!
        .saveRiskReport(
            uid, report.assessedAt.microsecondsSinceEpoch.toString(), report)
        .timeout(const Duration(seconds: 20));
    if (session?.uid != uid) {
      throw const AppFailure('Your session changed. Sign in and try again.');
    }
  }

  @override
  void dispose() {
    _generation++;
    _authSubscription?.cancel();
    _riskSubscription?.cancel();
    _projectSubscription?.cancel();
    super.dispose();
  }

  Project createProject(String name) {
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    projects.insert(0, project);
    _draftIds.add(project.id);
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
  Future<void> completeAnalysis(String projectId) async {
    final uid = session?.uid;
    if (backend != null && uid == null) {
      throw const AppFailure('Sign in to save reports.');
    }
    final project = projects.firstWhere((p) => p.id == projectId);
    final workers = project.numberOfWorkers ?? 10;
    final progress = project.percentComplete ?? 50;

    project.violations = const [
      Violation(
        title: 'Improper Column Spacing',
        description:
            'Columns are placed too close; structural integrity at risk.',
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

    if (backend != null) {
      await backend!
          .saveProject(uid!, project)
          .timeout(const Duration(seconds: 20));
      _draftIds.remove(project.id);
      if (session?.uid != uid) throw const AppFailure('Your session changed.');
    }
    notifyListeners();
  }
}
