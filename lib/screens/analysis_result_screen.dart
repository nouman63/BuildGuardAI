import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_badge.dart';
import '../widgets/violation_tile.dart';

class AnalysisResultScreen extends StatelessWidget {
  final String projectId;
  const AnalysisResultScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final project = state.projects.firstWhere((p) => p.id == projectId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Floor Plan Analysis Result'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                    'PROTOTYPE · Sample findings only. No AI model or regulatory validation has been performed.',
                    style: TextStyle(fontSize: 12, color: AppColors.amber))),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Project: ${project.name}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                RiskBadge(level: project.riskLevel),
              ],
            ),
            const SizedBox(height: 14),
            _FloorPlanPreview(project: project),
            const SizedBox(height: 20),
            if (project.riskSummary != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.insights_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        project.riskSummary!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.navy,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Row(
              children: [
                Expanded(
                  child: _miniStat(
                      'Workers', project.numberOfWorkers?.toString() ?? '—'),
                ),
                Expanded(
                  child: _miniStat(
                    'Progress',
                    project.percentComplete != null
                        ? '${project.percentComplete!.round()}%'
                        : '—',
                  ),
                ),
                Expanded(
                  child: _miniStat(
                      'Violations', project.violations.length.toString()),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Violation Report',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 12),
            if (project.violations.isEmpty)
              const Text(
                'No violations detected.',
                style: TextStyle(color: AppColors.textMuted),
              )
            else
              ...project.violations.map((v) => ViolationTile(violation: v)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Report generated and saved to project history.')),
                  );
                },
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('Generate Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        Text(label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
      ],
    );
  }
}

class _FloorPlanPreview extends StatelessWidget {
  final Project project;
  const _FloorPlanPreview({required this.project});

  @override
  Widget build(BuildContext context) {
    final path = project.floorPlanPath;
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (path != null)
            FutureBuilder<Uint8List>(
                future: XFile(path).readAsBytes(),
                builder: (context, snapshot) => snapshot.hasData
                    ? Image.memory(snapshot.data!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                            child: Text('Image preview unavailable')))
                    : const Center(
                        child: Icon(Icons.architecture_rounded,
                            color: AppColors.textMuted)))
          else
            const Center(
              child: Icon(Icons.architecture_rounded,
                  size: 48, color: AppColors.textMuted),
            ),
          if (project.violations.isNotEmpty)
            Positioned(
              left: 10,
              top: 10,
              child: _tag('${project.violations.length} issues flagged',
                  AppColors.danger),
            ),
        ],
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
