import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildguard_ai/main.dart';
import 'package:buildguard_ai/models/project.dart';
import 'package:buildguard_ai/models/risk_assessment.dart';
import 'package:buildguard_ai/services/app_backend.dart';
import 'package:buildguard_ai/services/report_codec.dart';
import 'package:buildguard_ai/state/app_state.dart';

RiskAssessment fixture() => RiskAssessment(
        name: 'Private house',
        type: 'Residential',
        location: 'Lahore',
        size: '10',
        unit: 'Marla',
        stage: 'Foundation',
        remaining: 'Roof',
        start: DateTime(2026, 1),
        completion: DateTime(2026, 12),
        assessedAt: DateTime(2026, 6),
        budget: 100,
        expenses: 90,
        progress: 10,
        workers: 4,
        skilled: 1,
        floors: 2,
        rooms: 12,
        unskilled: 3,
        labourCost: 20,
        materialCost: 60,
        otherExpenses: 10,
        materials: [
          const SiteMaterial(
              name: 'Cement',
              stock: 0,
              unit: 'Bags',
              condition: 'Damp',
              notes: 'Inspect')
        ]);

class FakeBackend implements AppBackend {
  final auth = StreamController<AuthSession?>.broadcast();
  final risk = <String, StreamController<List<RiskAssessment>>>{};
  final floor = <String, StreamController<List<Project>>>{};
  bool failSave = false, failLogout = false;
  String? savedUid, savedId, lastEmail, lastPassword;
  @override
  Stream<AuthSession?> get sessions => auth.stream;
  @override
  Stream<List<RiskAssessment>> watchRiskReports(String uid) =>
      (risk[uid] ??= StreamController<List<RiskAssessment>>.broadcast()).stream;
  @override
  Stream<List<Project>> watchProjects(String uid) =>
      (floor[uid] ??= StreamController<List<Project>>.broadcast()).stream;
  @override
  Future<void> login(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
  }

  @override
  Future<void> signUp(String name, String email, String password) async {
    lastEmail = email;
    lastPassword = password;
  }

  @override
  Future<void> logout() async {
    if (failLogout) throw const AppFailure('Failed to log out');
    auth.add(null);
  }

  @override
  Future<void> resetPassword(String email) async {
    lastEmail = email;
  }

  @override
  Future<void> saveRiskReport(
      String uid, String id, RiskAssessment report) async {
    if (failSave) throw const AppFailure('Save failed');
    savedUid = uid;
    savedId = id;
    risk[uid]!.add([report]);
  }

  @override
  Future<void> saveProject(String uid, Project project) async {
    if (failSave) throw const AppFailure('Save failed');
    savedUid = uid;
    floor[uid]!.add([project]);
  }

  Future<void> close() async {
    await auth.close();
    for (final c in risk.values) {
      await c.close();
    }
    for (final c in floor.values) {
      await c.close();
    }
  }
}

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  test('Failed floor report survives snapshot rollback and can be retried',
      () async {
    final backend = FakeBackend();
    final app = AppState(backend: backend);
    backend.auth.add(const AuthSession('alice', 'a@example.com', 'Alice'));
    await flush();
    final draft = app.createProject('Floor plan');
    backend.failSave = true;
    await expectLater(
        app.completeAnalysis(draft.id), throwsA(isA<AppFailure>()));
    backend.floor['alice']!.add([]);
    await flush();
    expect(app.projects.single.id, draft.id);
    backend.failSave = false;
    await app.completeAnalysis(draft.id);
    await flush();
    expect(backend.savedUid, 'alice');
    expect(app.projects.single.violations, isNotEmpty);
    app.dispose();
    await backend.close();
  });
  test('Stored risk report preserves inputs and original findings', () {
    final original = fixture();
    final restored = ReportCodec.riskFromMap(ReportCodec.riskToMap(original));
    expect(ReportCodec.riskToMap(restored), ReportCodec.riskToMap(original));
    expect(restored.assessedAt, DateTime(2026, 6));
  });
  test('Floor report round-trip excludes temporary local image paths', () {
    final p = Project(
        id: 'p1',
        name: 'Plan',
        createdAt: DateTime(2026),
        floorPlanPath: 'blob:temporary',
        riskLevel: RiskLevel.low);
    final restored =
        ReportCodec.projectFromMap(p.id, ReportCodec.projectToMap(p));
    expect(restored.id, 'p1');
    expect(restored.riskLevel, RiskLevel.low);
    expect(restored.floorPlanPath, isNull);
  });
  test('Restored auth scopes reports and switching accounts clears cached data',
      () async {
    final backend = FakeBackend();
    final app = AppState(backend: backend);
    expect(app.authReady, isFalse);
    backend.auth.add(const AuthSession('alice', 'a@example.com', 'Alice'));
    await flush();
    backend.risk['alice']!.add([fixture()]);
    backend.floor['alice']!.add([]);
    await flush();
    expect(app.riskReports.single.name, 'Private house');
    expect(app.reportsLoading, isFalse);
    backend.auth.add(const AuthSession('bob', 'b@example.com', 'Bob'));
    await flush();
    expect(app.riskReports, isEmpty);
    expect(app.projects, isEmpty);
    expect(app.userName, 'Bob');
    backend.risk['alice']!.add([fixture()]);
    await flush();
    expect(app.riskReports, isEmpty);
    await app.logout();
    await flush();
    expect(app.isLoggedIn, isFalse);
    expect(app.userName, isNull);
    expect(app.riskReports, isEmpty);
    app.dispose();
    await backend.close();
  });
  test(
      'Failed save remains an error and successful retry writes only to active UID',
      () async {
    final backend = FakeBackend();
    final app = AppState(backend: backend);
    backend.auth.add(const AuthSession('alice', 'a@example.com', 'Alice'));
    await flush();
    backend.failSave = true;
    await expectLater(
        app.saveRiskReport(fixture()), throwsA(isA<AppFailure>()));
    expect(app.riskReports, isEmpty);
    backend.failSave = false;
    final report = fixture();
    await app.saveRiskReport(report);
    await flush();
    expect(backend.savedUid, 'alice');
    expect(
        backend.savedId, report.assessedAt.microsecondsSinceEpoch.toString());
    expect(app.riskReports.length, 1);
    await app.login('a@example.com', 'actual-password');
    expect(backend.lastPassword, 'actual-password');
    backend.failLogout = true;
    await expectLater(app.logout(), throwsA(isA<AppFailure>()));
    expect(app.isLoggedIn, isTrue);
    app.dispose();
    await backend.close();
  });
  testWidgets(
      'Restored session opens Home; sign-out removes protected navigation',
      (tester) async {
    final backend = FakeBackend();
    final app = AppState(backend: backend);
    await tester.pumpWidget(BuildGuardApp(state: app));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    backend.auth.add(const AuthSession('alice', 'a@example.com', 'Alice'));
    await tester.pump();
    backend.risk['alice']!.add([]);
    backend.floor['alice']!.add([]);
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back!'), findsOneWidget);
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsWidgets);
    backend.auth.add(null);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Our Core Features'), findsOneWidget);
    expect(find.text('Alice'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await backend.close();
  });
}
