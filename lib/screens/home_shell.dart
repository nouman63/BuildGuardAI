import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_tab.dart';
import 'upload_floor_plan_screen.dart';
import 'risk_management_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _index, children: [
        DashboardTab(onModuleSelected: (i) => setState(() => _index = i)),
        const UploadFloorPlanScreen(embedded: true),
        const RiskManagementTab(),
      ]),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppColors.primarySoft,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textMuted,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.home_outlined, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined,
                  color: AppColors.textMuted),
              selectedIcon: Icon(Icons.space_dashboard_outlined,
                  color: AppColors.primary),
              label: 'Floor Plan',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: AppColors.textMuted),
              selectedIcon:
                  Icon(Icons.bar_chart_outlined, color: AppColors.primary),
              label: 'Risk',
            ),
          ],
        ),
      ),
    );
  }
}
