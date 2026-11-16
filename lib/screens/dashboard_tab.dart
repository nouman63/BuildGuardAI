import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/module_ui.dart';
import 'risk_management_tab.dart';

class DashboardTab extends StatelessWidget {
  final ValueChanged<int> onModuleSelected;
  const DashboardTab({super.key, required this.onModuleSelected});
  @override
  Widget build(BuildContext context) {
    final reports = context.watch<AppState>().riskReports;
    return SafeArea(
        child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
          Row(children: [
            const Expanded(child: AppLogo(size: 32)),
            IconButton.filledTonal(
                tooltip: 'Profile',
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                icon: const Icon(Icons.person_outline_rounded,
                    color: AppColors.primary, size: 20))
          ]),
          const SizedBox(height: 18),
          Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    AppColors.primarySoft,
                    AppColors.primarySoftStrong
                  ]),
                  borderRadius: BorderRadius.circular(18)),
              child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow('Authenticated'),
                    SizedBox(height: 8),
                    Text('Welcome Back!',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.7)),
                    SizedBox(height: 8),
                    Text(
                        'Your smarter way to analyze construction compliance and project risks.',
                        style: TextStyle(
                            fontSize: 12.5,
                            height: 1.7,
                            color: AppColors.textSecondary))
                  ])),
          const SizedBox(height: 24),
          const Eyebrow('Your Construction Assistant'),
          const SizedBox(height: 14),
          _module(
              Icons.space_dashboard_outlined,
              'Floor Plan Analysis',
              'Upload an architectural floor plan and use AI-powered computer vision to identify rooms, analyze layouts and detect potential building regulation violations.',
              'Analyze Floor Plan',
              AppColors.primary,
              AppColors.primarySoftStrong,
              1),
          _module(
              Icons.show_chart_rounded,
              'Risk Management',
              'Evaluate project schedules, workforce metrics and resource availability to identify potential delays and cost overruns.',
              'Open Risk Management',
              AppColors.amber,
              AppColors.amberSoft,
              2),
          const SizedBox(height: 10),
          const Eyebrow('Recent Activity'),
          const SizedBox(height: 14),
          if (reports.isEmpty)
            const ModulePanel(children: [
              Center(
                  child: Column(children: [
                Icon(Icons.history_rounded,
                    size: 30, color: AppColors.textMuted),
                SizedBox(height: 12),
                Text('No recent analyses',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('Upload your first floor plan to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ]))
            ]),
          for (final report in reports.take(3))
            Card(
                child: ListTile(
                    leading: const Icon(Icons.description_outlined,
                        color: AppColors.primary),
                    title: Text(report.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: Text('${report.level} risk · Prototype report',
                        style: const TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => Scaffold(
                                appBar:
                                    AppBar(title: const Text('Saved Report')),
                                body: RiskReportView(report: report)))))),
        ]));
  }

  Widget _module(IconData icon, String title, String description, String action,
          Color accent, Color background, int module) =>
      Container(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.primarySoftStrong),
              borderRadius: BorderRadius.circular(16)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                color: background,
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Icon(icon, color: accent, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        const Text('Active Feature',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w700))
                      ]))
                ])),
            Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description,
                          style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.7,
                              color: AppColors.textSecondary)),
                      if (module == 2) ...[
                        const SizedBox(height: 10),
                        const Text(
                            'Project inputs · Material inventory · Risk report',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600))
                      ],
                      const SizedBox(height: 12),
                      InkWell(
                          onTap: () => onModuleSelected(module),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(children: [
                                Text(action,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary)),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward,
                                    size: 15, color: AppColors.primary)
                              ]))),
                    ])),
          ]));
}
