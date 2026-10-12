import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';

class ProjectDataScreen extends StatefulWidget {
  final String projectId;
  const ProjectDataScreen({super.key, required this.projectId});

  @override
  State<ProjectDataScreen> createState() => _ProjectDataScreenState();
}

class _ProjectDataScreenState extends State<ProjectDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workers = TextEditingController();
  final _progress = TextEditingController();
  final _remaining = TextEditingController();

  @override
  void dispose() {
    _workers.dispose();
    _progress.dispose();
    _remaining.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AppState>().updateProjectData(
          projectId: widget.projectId,
          workers: int.parse(_workers.text.trim()),
          percentComplete: double.parse(_progress.text.trim()),
          remainingTasks: _remaining.text.trim(),
        );
    Navigator.pushNamed(context, '/analyzing', arguments: widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Enter Project Data'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tell us about current progress so BuildGuard AI can '
                  'predict construction risks.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Number of Workers',
                  hint: 'e.g. 20',
                  icon: Icons.groups_outlined,
                  controller: _workers,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Enter a valid number';
                    return null;
                  },
                ),
                AppTextField(
                  label: 'Work Completed (%)',
                  hint: 'e.g. 60',
                  icon: Icons.pie_chart_outline_rounded,
                  controller: _progress,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n < 0 || n > 100) {
                      return 'Enter a value between 0 and 100';
                    }
                    return null;
                  },
                ),
                AppTextField(
                  label: 'Remaining Tasks',
                  hint: 'e.g. Electrical wiring, drywall finishing',
                  icon: Icons.checklist_rounded,
                  controller: _remaining,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please describe remaining tasks'
                      : null,
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Submit', onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
