import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class ReportSyncStatus extends StatelessWidget {
  const ReportSyncStatus({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.syncError != null) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(children: [
            Text(state.syncError!,
                style: const TextStyle(fontSize: 12, color: Colors.red)),
            TextButton(
                onPressed: state.retryReports,
                child: const Text('Retry loading reports'))
          ]));
    }
    if (state.reportsLoading) {
      return const Padding(
          padding: EdgeInsets.all(12), child: LinearProgressIndicator());
    }
    return const SizedBox.shrink();
  }
}
