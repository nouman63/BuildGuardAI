import '../models/project.dart';
import '../models/risk_assessment.dart';

class AuthSession {
  final String uid;
  final String? email, name;
  const AuthSession(this.uid, this.email, this.name);
}

abstract class AppBackend {
  Stream<AuthSession?> get sessions;
  Future<void> login(String email, String password);
  Future<void> signUp(String name, String email, String password);
  Future<void> logout();
  Future<void> resetPassword(String email);
  Stream<List<RiskAssessment>> watchRiskReports(String uid);
  Stream<List<Project>> watchProjects(String uid);
  Future<void> saveRiskReport(String uid, String id, RiskAssessment report);
  Future<void> saveProject(String uid, Project project);
}

class AppFailure implements Exception {
  final String message;
  const AppFailure(this.message);
  @override
  String toString() => message;
}
