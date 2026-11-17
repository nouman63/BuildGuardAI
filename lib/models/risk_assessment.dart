class SiteMaterial {
  final String name;
  final double stock;
  final String unit;
  final String condition;
  final String notes;
  const SiteMaterial(
      {required this.name,
      required this.stock,
      required this.unit,
      required this.condition,
      this.notes = ''});
}

class ProjectRisk {
  final String title, category, level, reason, evidence, action;
  const ProjectRisk(this.title, this.category, this.level, this.reason,
      this.evidence, this.action);
}

/// Local, transparent heuristics for the interactive design prototype.
/// This is not an AI prediction or regulatory assessment.
class RiskAssessment {
  final String name, type, location, size, unit, stage, remaining;
  final DateTime start, completion;
  final double budget, expenses, progress;
  final int workers, skilled;
  final int floors, rooms, unskilled;
  final double labourCost, materialCost, otherExpenses;
  final List<SiteMaterial> materials;
  final List<ProjectRisk> risks;
  final DateTime assessedAt;

  RiskAssessment(
      {required this.name,
      required this.type,
      required this.location,
      required this.size,
      required this.unit,
      required this.stage,
      required this.remaining,
      required this.start,
      required this.completion,
      required this.budget,
      required this.expenses,
      required this.progress,
      required this.workers,
      required this.skilled,
      required this.materials,
      this.floors = 0,
      this.rooms = 0,
      int? unskilled,
      this.labourCost = 0,
      this.materialCost = 0,
      this.otherExpenses = 0,
      DateTime? assessedAt,
      List<ProjectRisk>? storedRisks})
      : unskilled = unskilled ?? workers - skilled,
        assessedAt = assessedAt ?? DateTime.now(),
        risks = [] {
    if (storedRisks != null) {
      risks.addAll(storedRisks);
      return;
    }
    final now = this.assessedAt;
    final duration = completion.difference(start).inDays;
    final elapsed = now.difference(start).inDays;
    final expected =
        duration > 0 ? (elapsed / duration * 100).clamp(0, 100) : 100;
    if (progress < 100 &&
        (completion.isBefore(now) || expected - progress > 15)) {
      risks.add(ProjectRisk(
          'Completion schedule is under pressure',
          'Schedule Delays',
          'High',
          'Reported progress is behind the elapsed project timeline.',
          '${progress.round()}% complete; target ${completion.day}/${completion.month}/${completion.year}. Remaining work: $remaining',
          'Create a weekly look-ahead schedule, assign trade owners and review critical-path progress.'));
    }
    if (budget > 0 && expenses / budget > progress / 100 + .2) {
      risks.add(ProjectRisk(
          'Cost contingency is narrowing',
          'Budget & Cost Overruns',
          expenses > budget ? 'High' : 'Medium',
          'Expenditure is high relative to reported construction progress.',
          '${(expenses / budget * 100).round()}% of the budget spent at ${progress.round()}% completion.',
          'Prepare a cost-to-complete forecast and review procurement before further spending.'));
    }
    if (progress < 100 && (workers == 0 || skilled / workers < .4)) {
      risks.add(ProjectRisk(
          'Available workforce may be insufficient',
          'Labour Shortages',
          workers == 0 ? 'High' : 'Medium',
          'Skilled labour availability needs review.',
          '$skilled skilled workers out of $workers total workers.',
          'Confirm trade availability and create a two-week labour allocation plan.'));
    }
    for (final material in materials) {
      if (material.stock <= 0 ||
          !['Good', 'Not Sure'].contains(material.condition)) {
        risks.add(ProjectRisk(
            '${material.name} requires attention',
            'Material Shortages',
            material.stock <= 0 ? 'High' : 'Medium',
            'Current inventory or material condition may affect construction work.',
            '${material.stock} ${material.unit}; condition: ${material.condition}. ${material.notes}',
            'Inspect the material, separate unsuitable stock and confirm replacement availability.'));
      }
    }
  }

  String get level => risks.any((r) => r.level == 'High')
      ? 'High'
      : risks.isNotEmpty
          ? 'Medium'
          : 'Low';
  static const categories = [
    'Schedule Delays',
    'Budget & Cost Overruns',
    'Labour Shortages',
    'Material Shortages',
    'Project Management Issues'
  ];
  String categoryLevel(String category) {
    final matches = risks.where((r) => r.category == category);
    if (category == 'Material Shortages' && materials.isEmpty) {
      return 'Not assessed';
    }
    if (matches.any((r) => r.level == 'High')) return 'High';
    return matches.isEmpty ? 'No Major Risk Identified' : 'Medium';
  }
}
