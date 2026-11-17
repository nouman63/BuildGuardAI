import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../models/risk_assessment.dart';
import 'app_backend.dart';
import 'report_codec.dart';

class FirebaseBackend implements AppBackend {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  FirebaseBackend({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;
  @override
  Stream<AuthSession?> get sessions => _auth.userChanges().map(
      (u) => u == null ? null : AuthSession(u.uid, u.email, u.displayName));
  @override
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signUp(String name, String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await result.user!.updateDisplayName(name);
  }

  @override
  Future<void> logout() => _auth.signOut();
  @override
  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);
  CollectionReference<Map<String, dynamic>> collection(
          String uid, String name) =>
      _db.collection('users').doc(uid).collection(name);
  @override
  Stream<List<RiskAssessment>> watchRiskReports(String uid) =>
      collection(uid, 'riskReports')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) =>
              s.docs.map((d) => ReportCodec.riskFromMap(d.data())).toList());
  @override
  Stream<List<Project>> watchProjects(
          String uid) =>
      collection(uid, 'floorReports')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs
              .map((d) => ReportCodec.projectFromMap(d.id, d.data()))
              .toList());
  @override
  Future<void> saveRiskReport(String uid, String id, RiskAssessment report) =>
      collection(uid, 'riskReports').doc(id).set({
        ...ReportCodec.riskToMap(report),
        'ownerId': uid,
        'createdAt': Timestamp.fromDate(report.assessedAt),
      });
  @override
  Future<void> saveProject(String uid, Project project) =>
      collection(uid, 'floorReports').doc(project.id).set({
        ...ReportCodec.projectToMap(project),
        'ownerId': uid,
        'createdAt': Timestamp.fromDate(project.createdAt),
      });
}

String friendlyError(Object error) {
  if (error is TimeoutException) {
    return 'Saving is taking longer than expected. Check your connection and retry; your report inputs are retained.';
  }
  if (error is AppFailure) return error.message;
  if (error is FirebaseException) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' =>
        'Email or password is incorrect.',
      'email-already-in-use' =>
        'An account already exists for this email. Try logging in.',
      'weak-password' =>
        'Choose a stronger password with at least 8 characters.',
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' ||
      'unavailable' =>
        'Cannot reach Firebase. Check your connection and try again.',
      'permission-denied' =>
        'Reports could not be accessed. Check the Firestore rules for your project.',
      'operation-not-allowed' =>
        'Enable Email/Password sign-in in Firebase Authentication.',
      _ => 'The request could not be completed. Please try again.',
    };
  }
  return 'The request could not be completed. Please try again.';
}
