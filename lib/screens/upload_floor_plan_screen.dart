import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';

class UploadFloorPlanScreen extends StatefulWidget {
  const UploadFloorPlanScreen({super.key});

  @override
  State<UploadFloorPlanScreen> createState() => _UploadFloorPlanScreenState();
}

class _UploadFloorPlanScreenState extends State<UploadFloorPlanScreen> {
  final _nameController = TextEditingController(text: 'New Project');
  XFile? _pickedImage;
  bool _picking = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _picking = true);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 2000,
        imageQuality: 90,
      );
      if (file != null) setState(() => _pickedImage = file);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not access image source.')),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _next() {
    if (_nameController.text.trim().isEmpty) return;
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a floor plan image (JPG or PNG).')),
      );
      return;
    }
    final project = context.read<AppState>().createProject(
          _nameController.text.trim(),
        );
    project.floorPlanPath = _pickedImage!.path;
    Navigator.pushNamed(context, '/project-data', arguments: project.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Upload Floor Plan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Project Name',
                hint: 'e.g. New Office Building',
                icon: Icons.apartment_rounded,
                controller: _nameController,
              ),
              const Text(
                'Upload your floor plan for analysis',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _picking ? null : () => _pickImage(ImageSource.gallery),
                child: DottedBox(
                  child: _pickedImage == null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.cloud_upload_outlined,
                                  color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                              ),
                              child: const Text(
                                'Upload Image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: _picking
                                  ? null
                                  : () => _pickImage(ImageSource.camera),
                              child: const Text('Or Take a Photo'),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Image.file(
                            File(_pickedImage!.path),
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              if (_pickedImage != null) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Choose a different image'),
                ),
              ],
              const SizedBox(height: 8),
              const Text(
                'Accepted formats: JPG, PNG · Max size 10MB',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),
              PrimaryButton(label: 'Next', onPressed: _next),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedBox extends StatelessWidget {
  final Widget child;
  const DottedBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.divider,
          width: 1.4,
        ),
      ),
      child: Center(child: child),
    );
  }
}
