import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/feature_card.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Expanded(
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: AppLogo(size: 30))),
                      TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          child: const Text('Login',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy))),
                      ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/signup'),
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 38),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              textStyle: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                          child: const Text('Sign Up')),
                    ]),
                    const SizedBox(height: 24),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            border:
                                Border.all(color: AppColors.primarySoftStrong),
                            borderRadius: BorderRadius.circular(99)),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_outlined,
                                  size: 14, color: AppColors.primary),
                              SizedBox(width: 6),
                              Flexible(
                                  child: Text('BUILD SMARTER · SAFER · FASTER',
                                      style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: .4,
                                          color: AppColors.primary)))
                            ])),
                    const SizedBox(height: 16),
                    const Text.rich(TextSpan(
                        style: TextStyle(
                            fontSize: 30,
                            height: 1.15,
                            letterSpacing: -.75,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy),
                        children: [
                          TextSpan(text: 'AI-Powered '),
                          TextSpan(
                              text: 'Construction ',
                              style: TextStyle(color: AppColors.primary)),
                          TextSpan(text: 'Compliance & '),
                          TextSpan(
                              text: 'Risk Management',
                              style: TextStyle(color: AppColors.primary)),
                        ])),
                    const SizedBox(height: 14),
                    const Text(
                        'BuildGuard AI helps architects, engineers and project managers detect building regulation violations and identify project risks before construction begins.',
                        style: TextStyle(
                            fontSize: 13.5,
                            height: 1.7,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 26),
                    const Row(children: [
                      Expanded(
                          child: Divider(color: AppColors.primarySoftStrong)),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('CORE MODULES',
                              style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary))),
                      Expanded(
                          child: Divider(color: AppColors.primarySoftStrong))
                    ]),
                    const SizedBox(height: 8),
                    const Center(
                        child: Text('Our Core Features',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.3))),
                    const SizedBox(height: 16),
                    const FeatureCard(
                        icon: Icons.grid_view_rounded,
                        title: 'Floor Plan Analysis',
                        subtitle: 'Computer Vision · Regulation AI',
                        description:
                            'Uses computer vision to scan architectural plans and detect potential structural and regulatory violations against regional bylaws such as LDA standards.',
                        tags: ['CV Model', 'LDA Bylaws', 'Auto-flagging'],
                        headerBg: AppColors.primarySoftStrong,
                        pillBg: AppColors.primarySoft,
                        accent: AppColors.primary),
                    const SizedBox(height: 12),
                    const FeatureCard(
                        icon: Icons.show_chart_rounded,
                        title: 'Risk Management',
                        subtitle: 'Machine Learning · Predictive AI',
                        description:
                            'Uses machine learning to evaluate project schedules, workforce metrics and resource availability to predict delays and cost overruns.',
                        tags: [
                          'ML Model',
                          'Delay Prediction',
                          'Cost Forecasting'
                        ],
                        headerBg: AppColors.amberSoft,
                        pillBg: AppColors.amberSoft,
                        accent: AppColors.amber),
                    const SizedBox(height: 24),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(22, 32, 22, 26),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.navy,
                                  Color(0xFF163171),
                                  Color(0xFF1A3060)
                                ])),
                        child: Column(children: [
                          const Text('POWERED BY ARTIFICIAL INTELLIGENCE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 9.5,
                                  letterSpacing: 2,
                                  color: Color(0xFF93C5FD),
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 18),
                          const Text('BETTER INSIGHTS.\nSAFER BUILDS.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22,
                                  height: 1.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          const Text('A SMARTER TOMORROW.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  height: 1.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF93C5FD))),
                          const SizedBox(height: 24),
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/login'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16))),
                                  child: const Text('Login'))),
                          const SizedBox(height: 12),
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/signup'),
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16))),
                                  child: const Text("Sign Up — It's Free"))),
                          const SizedBox(height: 18),
                          const Text(
                              'BuildGuard AI · Smart Construction Risk Analysis',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10.5, color: Color(0xA693C5FD))),
                        ])),
                  ]))));
}
