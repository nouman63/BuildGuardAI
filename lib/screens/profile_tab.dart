import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'history_tab.dart';
import 'risk_management_tab.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.primarySoft,
              child: Text(
                (state.userName?.isNotEmpty == true ? state.userName![0] : '?')
                    .toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              state.userName ?? 'Guest',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ),
          Center(
            child: Text(
              state.userEmail ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text('ACCOUNT INFORMATION',
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _tile(Icons.person_outline, 'Username',
              subtitle: state.userName ?? 'Guest'),
          _tile(Icons.mail_outline, 'Email', subtitle: state.userEmail ?? ''),
          _tile(Icons.lock_outline, 'Password', subtitle: '••••••••'),
          const SizedBox(height: 16),
          const Text('REPORTS & SETTINGS',
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _tile(Icons.description_outlined, 'Saved Reports',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Scaffold(
                          appBar: AppBar(title: const Text('Saved Reports')),
                          body: state.riskReports.isEmpty
                              ? const Center(
                                  child: Text('No saved risk reports yet.'))
                              : ListView(children: [
                                  for (final report in state.riskReports)
                                    ListTile(
                                        title: Text(report.name),
                                        subtitle: Text('${report.level} risk'),
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => Scaffold(
                                                    appBar: AppBar(
                                                        title: const Text(
                                                            'Saved Report')),
                                                    body: RiskReportView(
                                                        report: report))))),
                                ]))))),
          _tile(Icons.history, 'Floor Plan History',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Scaffold(
                          appBar:
                              AppBar(title: const Text('Floor Plan History')),
                          body: const HistoryTab())))),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AppState>().logout();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label,
      {String? subtitle, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: subtitle == null
            ? null
            : Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: onTap == null
            ? null
            : const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
