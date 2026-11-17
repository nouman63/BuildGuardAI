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
import 'package:firebase_core/firebase_core.dart';
import 'firebase_configuration.dart';
import 'services/firebase_backend.dart';
import 'screens/firebase_setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: FirebaseConfiguration.currentPlatform);
    runApp(BuildGuardApp(state: AppState(backend: FirebaseBackend())));
  } catch (_) {
    runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const FirebaseSetupScreen()));
  }
}

class BuildGuardApp extends StatefulWidget {
  final AppState? state;
  const BuildGuardApp({super.key, this.state});
  @override
  State<BuildGuardApp> createState() => _BuildGuardAppState();
}

class _BuildGuardAppState extends State<BuildGuardApp> {
  late final AppState state = widget.state ?? AppState();
  final navigator = GlobalKey<NavigatorState>();
  String? _uid;
  @override
  void initState() {
    super.initState();
    _uid = state.session?.uid;
    state.addListener(_sessionChanged);
  }

  void _sessionChanged() {
    final uid = state.session?.uid;
    if (uid == _uid) return;
    _uid = uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        navigator.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      }
    });
  }

  @override
  void dispose() {
    state.removeListener(_sessionChanged);
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: state,
      child: MaterialApp(
        navigatorKey: navigator,
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
              return MaterialPageRoute(
                  builder: (_) => Consumer<AppState>(
                      builder: (context, state, _) => !state.authReady
                          ? const Scaffold(
                              body: Center(child: CircularProgressIndicator()))
                          : state.isLoggedIn
                              ? const HomeShell()
                              : const LandingScreen()));
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/signup':
              return MaterialPageRoute(builder: (_) => const SignupScreen());
            case '/home':
              return MaterialPageRoute(
                  builder: (_) => const _SignedIn(child: HomeShell()));
            case '/profile':
              return MaterialPageRoute(
                  builder: (_) => _SignedIn(
                      child: Scaffold(
                          appBar: AppBar(title: const Text('Profile')),
                          body: const ProfileTab())));
            case '/upload':
              return MaterialPageRoute(
                  builder: (_) =>
                      const _SignedIn(child: UploadFloorPlanScreen()));
            case '/project-data':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                  builder: (_) =>
                      _SignedIn(child: ProjectDataScreen(projectId: id)));
            case '/analyzing':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                  builder: (_) =>
                      _SignedIn(child: AnalyzingScreen(projectId: id)));
            case '/result':
              final id = settings.arguments as String;
              return MaterialPageRoute(
                  builder: (_) =>
                      _SignedIn(child: AnalysisResultScreen(projectId: id)));
            default:
              return MaterialPageRoute(builder: (_) => const LandingScreen());
          }
        },
      ),
    );
  }
}

class _SignedIn extends StatelessWidget {
  final Widget child;
  const _SignedIn({required this.child});
  @override
  Widget build(BuildContext context) =>
      context.watch<AppState>().isLoggedIn ? child : const LandingScreen();
}
