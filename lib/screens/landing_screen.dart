import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/feature_card.dart';

/// The pre-login landing screen — matches the Figma "Mobile App Landing
/// Page Design" export: logo header with Login/Sign Up, hero headline,
/// and the two core-feature cards (Floor Plan Analysis, Risk Management).
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(child: AppLogo(size: 30)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18),
                      textStyle: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'BUILD SMARTER · SAFER · FASTER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Headline
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.18,
                    fontWeight: FontWeight.w800,
                  ),
                  children: [
                    const TextSpan(
                        text: 'AI-Powered ',
                        style: TextStyle(color: AppColors.navy)),
                    const TextSpan(
                        text: 'Construction ',
                        style: TextStyle(color: AppColors.primary)),
                    const TextSpan(
                        text: 'Compliance & ',
                        style: TextStyle(color: AppColors.navy)),
                    const TextSpan(
                        text: 'Risk Management',
                        style: TextStyle(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'BuildGuard AI helps architects, engineers and project '
                'managers detect building regulation violations and '
                'identify project risks before construction begins.',
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 30),

              // Section divider label
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'CORE MODULES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Our Core Features',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 18),

              FeatureCard(
                icon: Icons.grid_view_rounded,
                title: 'Floor Plan Analysis',
                subtitle: 'Computer Vision · Regulation AI',
                description:
                    'Uses computer vision to scan architectural plans and '
                    'detect potential structural and regulatory violations '
                    'against regional bylaws and construction standards.',
                tags: const ['CV Model', 'Compliance Rules', 'Auto-flagging'],
                headerBg: AppColors.primarySoftStrong,
                pillBg: AppColors.primarySoft,
                accent: AppColors.primary,
              ),
              const SizedBox(height: 16),
              FeatureCard(
                icon: Icons.show_chart_rounded,
                title: 'Risk Management',
                subtitle: 'Machine Learning · Predictive AI',
                description:
                    'Uses machine learning to evaluate project schedules, '
                    'workforce metrics and resource availability to predict '
                    'delays and cost overruns.',
                tags: const [
                  'ML Model',
                  'Delay Prediction',
                  'Cost Forecasting'
                ],
                headerBg: AppColors.amberSoft,
                pillBg: AppColors.amberSoft,
                accent: AppColors.amber,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    'Already have an account? Log In',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
