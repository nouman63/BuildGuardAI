import 'package:flutter_test/flutter_test.dart';
import 'package:buildguard_ai/models/risk_assessment.dart';

RiskAssessment assess(
        {double progress = 35,
        double expenses = 6100000,
        int workers = 12,
        int skilled = 4,
        List<SiteMaterial> materials = const []}) =>
    RiskAssessment(
        name: 'Green Residency House',
        type: 'Residential',
        location: 'Lahore, Pakistan',
        size: '10',
        unit: 'Marla',
        stage: 'Grey Structure',
        remaining: 'Roof, MEP and finishing',
        start: DateTime(2026, 6),
        completion: DateTime(2027, 2, 28),
        budget: 8500000,
        expenses: expenses,
        progress: progress,
        workers: workers,
        skilled: skilled,
        materials: materials,
        assessedAt: DateTime(2026, 11, 16));

void main() {
  test('Behind-schedule project flags schedule, cost and labour evidence', () {
    final report = assess();
    expect(report.level, 'High');
    expect(report.categoryLevel('Schedule Delays'), 'High');
    expect(report.categoryLevel('Budget & Cost Overruns'), 'Medium');
    expect(report.categoryLevel('Labour Shortages'), 'Medium');
    expect(report.categoryLevel('Material Shortages'), 'Not assessed');
    expect(
        report.risks.every((r) => r.evidence.isNotEmpty && r.action.isNotEmpty),
        isTrue);
  });
  test('Healthy project does not inherit the sample report risks', () {
    final report = assess(progress: 90, expenses: 4000000, skilled: 8);
    expect(report.level, 'Low');
    expect(report.risks, isEmpty);
  });
  test('Unavailable or damaged inventory contributes to report', () {
    final report =
        assess(progress: 90, expenses: 4000000, skilled: 8, materials: [
      const SiteMaterial(
          name: 'Cement', stock: 0, unit: 'Bags', condition: 'Good'),
      const SiteMaterial(
          name: 'Steel', stock: 2, unit: 'Tons', condition: 'Damaged'),
    ]);
    expect(report.level, 'High');
    expect(report.categoryLevel('Material Shortages'), 'High');
    expect(report.risks.length, 2);
  });
  test('Zero labour is handled without division errors', () {
    expect(assess(workers: 0, skilled: 0).categoryLevel('Labour Shortages'),
        'High');
  });
}
