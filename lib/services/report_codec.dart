import '../models/project.dart';
import '../models/risk_assessment.dart';
import '../models/violation.dart';

/// Store the findings as generated; loading a report must not rerun today's rules.
class ReportCodec {
  static Map<String, dynamic> riskToMap(RiskAssessment r) => {
        'schemaVersion': 1,
        'name': r.name,
        'type': r.type,
        'location': r.location,
        'size': r.size,
        'unit': r.unit,
        'stage': r.stage,
        'remaining': r.remaining,
        'start': r.start.toIso8601String(),
        'completion': r.completion.toIso8601String(),
        'assessedAt': r.assessedAt.toIso8601String(),
        'budget': r.budget,
        'expenses': r.expenses,
        'progress': r.progress,
        'workers': r.workers,
        'skilled': r.skilled,
        'unskilled': r.unskilled,
        'floors': r.floors,
        'rooms': r.rooms,
        'labourCost': r.labourCost,
        'materialCost': r.materialCost,
        'otherExpenses': r.otherExpenses,
        'materials': r.materials
            .map((m) => {
                  'name': m.name,
                  'stock': m.stock,
                  'unit': m.unit,
                  'condition': m.condition,
                  'notes': m.notes
                })
            .toList(),
        'risks': r.risks
            .map((v) => {
                  'title': v.title,
                  'category': v.category,
                  'level': v.level,
                  'reason': v.reason,
                  'evidence': v.evidence,
                  'action': v.action
                })
            .toList(),
      };

  static RiskAssessment riskFromMap(Map<String, dynamic> d) => RiskAssessment(
        name: d['name'] as String,
        type: d['type'] as String,
        location: d['location'] as String,
        size: d['size'] as String,
        unit: d['unit'] as String,
        stage: d['stage'] as String,
        remaining: d['remaining'] as String,
        start: DateTime.parse(d['start'] as String),
        completion: DateTime.parse(d['completion'] as String),
        assessedAt: DateTime.parse(d['assessedAt'] as String),
        budget: (d['budget'] as num).toDouble(),
        expenses: (d['expenses'] as num).toDouble(),
        progress: (d['progress'] as num).toDouble(),
        workers: (d['workers'] as num).toInt(),
        skilled: (d['skilled'] as num).toInt(),
        unskilled: (d['unskilled'] as num?)?.toInt(),
        floors: (d['floors'] as num?)?.toInt() ?? 0,
        rooms: (d['rooms'] as num?)?.toInt() ?? 0,
        labourCost: (d['labourCost'] as num?)?.toDouble() ?? 0,
        materialCost: (d['materialCost'] as num?)?.toDouble() ?? 0,
        otherExpenses: (d['otherExpenses'] as num?)?.toDouble() ?? 0,
        materials: (d['materials'] as List)
            .map((v) => SiteMaterial(
                name: v['name'] as String,
                stock: (v['stock'] as num).toDouble(),
                unit: v['unit'] as String,
                condition: v['condition'] as String,
                notes: v['notes'] as String))
            .toList(),
        storedRisks: (d['risks'] as List)
            .map((v) => ProjectRisk(
                v['title'] as String,
                v['category'] as String,
                v['level'] as String,
                v['reason'] as String,
                v['evidence'] as String,
                v['action'] as String))
            .toList(),
      );

  static Map<String, dynamic> projectToMap(Project p) => {
        'schemaVersion': 1, 'name': p.name,
        'createdAtIso': p.createdAt.toIso8601String(),
        'workers': p.numberOfWorkers, 'progress': p.percentComplete,
        'remaining': p.remainingTasks,
        'riskLevel': p.riskLevel.name, 'riskSummary': p.riskSummary,
        // A device path / web blob URL is not a durable cloud image reference.
        'violations': p.violations
            .map((v) => {
                  'title': v.title,
                  'description': v.description,
                  'severity': v.severity.name
                })
            .toList(),
      };
  static Project projectFromMap(String id, Map<String, dynamic> d) => Project(
        id: id,
        name: d['name'] as String,
        createdAt: DateTime.parse(d['createdAtIso'] as String),
        numberOfWorkers: (d['workers'] as num?)?.toInt(),
        percentComplete: (d['progress'] as num?)?.toDouble(),
        remainingTasks: d['remaining'] as String?,
        riskLevel: RiskLevel.values.byName(d['riskLevel'] as String),
        riskSummary: d['riskSummary'] as String?,
        violations: (d['violations'] as List)
            .map((v) => Violation(
                title: v['title'] as String,
                description: v['description'] as String,
                severity: Severity.values.byName(v['severity'] as String)))
            .toList(),
      );
}
