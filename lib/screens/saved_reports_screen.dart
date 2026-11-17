import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/report_sync_status.dart';
import 'risk_management_tab.dart';

class SavedReportsScreen extends StatelessWidget {
  const SavedReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
        appBar: AppBar(title: const Text('Saved Reports')),
        body: ListView(children: [
          const ReportSyncStatus(),
          if (state.riskReports.isEmpty &&
              !state.reportsLoading &&
              state.syncError == null)
            const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No saved risk reports yet.')),
          for (final report in state.riskReports)
            ListTile(
                title: Text(report.name),
                subtitle: Text('${report.level} risk'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => Scaffold(
                            appBar: AppBar(title: const Text('Saved Report')),
                            body: RiskReportView(report: report))))),
        ]));
  }
}
