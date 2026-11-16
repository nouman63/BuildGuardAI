import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/module_ui.dart';

class UploadFloorPlanScreen extends StatefulWidget {
  final bool embedded;
  const UploadFloorPlanScreen({super.key, this.embedded = false});
  @override
  State<UploadFloorPlanScreen> createState() => _UploadFloorPlanScreenState();
}

class _UploadFloorPlanScreenState extends State<UploadFloorPlanScreen> {
  XFile? _file;
  Uint8List? _bytes;
  bool _picking = false;
  Future<void> pick(ImageSource source) async {
    setState(() => _picking = true);
    try {
      final file = await ImagePicker()
          .pickImage(source: source, maxWidth: 2000, imageQuality: 90);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 10 * 1024 * 1024) {
        message('Please select an image smaller than 10MB.');
        return;
      }
      final name = file.name.toLowerCase();
      if (!['.png', '.jpg', '.jpeg'].any(name.endsWith)) {
        message('Please select a PNG, JPG or JPEG image.');
        return;
      }
      setState(() {
        _file = file;
        _bytes = bytes;
      });
    } catch (_) {
      if (mounted) {
        message(
            'Could not access the image source. Try choosing an image from your device.');
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  void analyze() {
    if (_file == null) {
      message('Please choose a floor plan image first.');
      return;
    }
    final project = context.read<AppState>().createProject(_file!.name);
    project.floorPlanPath = _file!.path;
    Navigator.pushNamed(context, '/analyzing', arguments: project.id);
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
      const ModuleHeading('Floor Plan Analysis',
          'Analyze your architectural floor plan with AI-powered computer vision.'),
      const ModulePanel(title: 'What can BuildGuard AI detect?', children: [
        _Capability(Icons.grid_view_rounded, 'Room Detection',
            'Identify rooms and spaces within the uploaded floor plan.'),
        _Capability(Icons.dashboard_outlined, 'Layout Analysis',
            'Analyze the arrangement and spatial layout of the building.'),
        _Capability(Icons.straighten, 'Dimension Analysis',
            'Examine important room and structural dimensions.'),
        _Capability(Icons.border_outer, 'Boundary & Setback',
            'Identify potential boundary or setback issues.'),
        _Capability(Icons.verified_user_outlined, 'Regulation Compliance',
            'Compare detected elements against applicable LDA standards.'),
        _Capability(Icons.report_outlined, 'Violation Detection',
            'Highlight potential structural or regulatory violations.'),
      ]),
      ModulePanel(title: 'Upload Your Floor Plan', children: [
        const Text(
            'Upload a clear architectural floor plan image for analysis.',
            style: TextStyle(
                fontSize: 12, color: AppColors.textSecondary, height: 1.6)),
        const SizedBox(height: 18),
        Semantics(
            button: true,
            label: 'Choose floor plan image',
            child: InkWell(
                onTap: _picking ? null : () => pick(ImageSource.gallery),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        border: Border.all(color: AppColors.primarySoftStrong),
                        borderRadius: BorderRadius.circular(14)),
                    child: _bytes == null
                        ? const Column(children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: 38, color: AppColors.primary),
                            SizedBox(height: 12),
                            Text('Upload Floor Plan',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary)),
                            SizedBox(height: 6),
                            Text('Choose an image from your device',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary))
                          ])
                        : Column(children: [
                            Image.memory(_bytes!,
                                height: 180,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Text(
                                    'Could not display this image. Please choose another.')),
                            const SizedBox(height: 10),
                            Text(_file!.name,
                                style: const TextStyle(fontSize: 11)),
                            const Text('Tap to change image',
                                style: TextStyle(
                                    fontSize: 10, color: AppColors.primary))
                          ])))),
        const SizedBox(height: 12),
        Center(
            child: TextButton.icon(
                onPressed: _picking ? null : () => pick(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Take a Photo'))),
        const Center(
            child: Text('Supported formats: PNG, JPG or JPEG · Max 10MB',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted))),
        const SizedBox(height: 18),
        ModuleButton(_picking ? 'Opening image source…' : 'Upload Floor Plan',
            onPressed: _picking ? null : analyze, icon: Icons.upload_outlined),
      ]),
      const ModulePanel(children: [
        Text(
            'BuildGuard AI detects potential violations for review purposes only. Results do not constitute official legal approval or regulatory clearance.',
            style: TextStyle(
                fontSize: 11, color: AppColors.textSecondary, height: 1.7)),
        SizedBox(height: 8),
        Text(
            'Prototype: analysis currently uses sample results, not an AI model.',
            style: TextStyle(
                fontSize: 11,
                color: AppColors.amber,
                fontWeight: FontWeight.w600))
      ]),
    ]));
    return widget.embedded
        ? body
        : Scaffold(appBar: AppBar(leading: const BackButton()), body: body);
  }
}

class _Capability extends StatelessWidget {
  final IconData icon;
  final String title, description;
  const _Capability(this.icon, this.title, this.description);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: AppColors.primary, size: 18)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(description,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary, height: 1.6))
        ]))
      ]));
}
