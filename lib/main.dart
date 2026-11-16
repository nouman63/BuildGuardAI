import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/analysis_result_screen.dart';
import 'screens/analyzing_screen.dart';
import 'screens/home_shell.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/project_data_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/upload_floor_plan_screen.dart';
import 'screens/profile_tab.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BuildGuardApp());
}

class BuildGuardApp extends StatelessWidget {
  const BuildGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'BuildGuard AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (context, child) => ColoredBox(
          color: const Color(0xFFD1E3FF),
          child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: child!)),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const LandingScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/signup':
              return MaterialPageRoute(builder: (_) => const SignupScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => const HomeShell());
            case '/profile':
              return MaterialPageRoute(
                  builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Profile')),
                      body: const ProfileTab()));
            case '/upload':
              return MaterialPageRoute(
                  builder: (_) => const UploadFloorPlanScreen());
            case '/project-data':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                  builder: (_) => ProjectDataScreen(projectId: id));
            case '/analyzing':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                  builder: (_) => AnalyzingScreen(projectId: id));
            case '/result':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                  builder: (_) => AnalysisResultScreen(projectId: id));
            default:
              return MaterialPageRoute(builder: (_) => const LandingScreen());
          }
        },
      ),
    );
  }
}
