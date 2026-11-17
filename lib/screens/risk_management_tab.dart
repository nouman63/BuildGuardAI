import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../models/risk_assessment.dart';
import '../state/app_state.dart';
import '../services/firebase_backend.dart';
import '../theme/app_theme.dart';
import '../widgets/module_ui.dart';

class RiskManagementTab extends StatefulWidget {
  const RiskManagementTab({super.key});
  @override
  State<RiskManagementTab> createState() => _RiskManagementTabState();
}

class _RiskManagementTabState extends State<RiskManagementTab> {
  final _form = GlobalKey<FormState>();
  final _fields = <String, TextEditingController>{
    for (final key in [
      'Project Name',
      'Location',
      'Number of Floors',
      'Number of Rooms',
      'Project Size',
      'Estimated Budget (PKR)',
      'Labour Cost So Far (PKR)',
      'Material Cost So Far (PKR)',
      'Other Expenses So Far (PKR)',
      'Total Workers',
      'Skilled Workers',
      'Unskilled Workers',
      'Remaining Work'
    ])
      key: TextEditingController(),
  };
  String _type = 'Residential', _unit = 'Marla', _stage = 'Foundation';
  DateTime? _start, _completion;
  double _progress = 0;
  int _step = 0;
  final List<SiteMaterial> _materials = [];
  RiskAssessment? _report;
  RiskAssessment? _pendingReport;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double number(String key) => double.tryParse(_fields[key]!.text) ?? 0;
  double get expenses =>
      number('Labour Cost So Far (PKR)') +
      number('Material Cost So Far (PKR)') +
      number('Other Expenses So Far (PKR)');

  Widget field(String label,
          {bool numeric = false,
          bool integer = false,
          bool optional = false,
          int lines = 1}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextFormField(
              controller: _fields[label],
              maxLines: lines,
              keyboardType: numeric
                  ? TextInputType.numberWithOptions(decimal: !integer)
                  : TextInputType.text,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                  labelText: label,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: optional ? '0' : 'Enter ${label.toLowerCase()}',
                  labelStyle: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return optional ? null : 'Required';
                }
                if (numeric) {
                  final n = double.tryParse(value!);
                  if (n == null ||
                      !n.isFinite ||
                      n < 0 ||
                      (integer && n != n.roundToDouble())) {
                    return 'Enter a valid ${integer ? 'whole ' : ''}number';
                  }
                  if ([
                        'Estimated Budget (PKR)',
                        'Project Size',
                        'Number of Floors',
                        'Number of Rooms'
                      ].contains(label) &&
                      n == 0) {
                    return 'Must be greater than zero';
                  }
                }
                return null;
              }));

  Widget select(String label, String value, List<String> options,
          ValueChanged<String> change) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: DropdownButtonFormField<String>(
              initialValue: value,
              isExpanded: true,
              style: const TextStyle(fontSize: 12, color: AppColors.navy),
              decoration: InputDecoration(
                  labelText: label,
                  floatingLabelBehavior: FloatingLabelBehavior.always),
              items: options
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => change(v!))));

  Widget pair(Widget first, Widget second) => LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 300
          ? Column(children: [first, second])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: first),
              const SizedBox(width: 12),
              Expanded(child: second)
            ]));

  Future<void> pickDate(bool start) async {
    final date = await showDatePicker(
        context: context,
        initialDate: (start ? _start : _completion) ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (date != null && mounted) {
      setState(() {
        if (start) {
          _start = date;
        } else {
          _completion = date;
        }
      });
    }
  }

  Widget dateField(String label, DateTime? value, bool start) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FormField<DateTime>(
          validator: (_) => value == null ? 'Select a date' : null,
          builder: (state) => InkWell(
              onTap: () => pickDate(start),
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                  decoration: InputDecoration(
                      labelText: label,
                      errorText: state.errorText,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon:
                          const Icon(Icons.calendar_today_outlined, size: 16)),
                  child: Text(
                      value == null
                          ? 'Select date'
                          : DateFormat('dd MMM yyyy').format(value),
                      style: const TextStyle(fontSize: 11))))));

  void next() {
    if (!_form.currentState!.validate()) return;
    if (!_completion!.isAfter(_start!)) {
      message('Completion must be after the start date.');
      return;
    }
    if (number('Skilled Workers') + number('Unskilled Workers') !=
        number('Total Workers')) {
      message('Skilled and unskilled workers must add up to total workers.');
      return;
    }
    setState(() {
      _pendingReport = null;
      _step = 1;
    });
  }

  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> editMaterial([int? index]) async {
    final existing = index == null ? null : _materials[index];
    final material = await showDialog<SiteMaterial>(
        context: context, builder: (_) => _MaterialDialog(material: existing));
    if (material != null && mounted) {
      setState(() {
        _pendingReport = null;
        if (index == null) {
          _materials.add(material);
        } else {
          _materials[index] = material;
        }
      });
    }
  }

  Future<void> generate() async {
    if (_saving) return;
    final report = _pendingReport ??
        RiskAssessment(
            name: _fields['Project Name']!.text.trim(),
            type: _type,
            location: _fields['Location']!.text.trim(),
            size: _fields['Project Size']!.text,
            unit: _unit,
            stage: _stage,
            remaining: _fields['Remaining Work']!.text.trim(),
            start: _start!,
            completion: _completion!,
            budget: number('Estimated Budget (PKR)'),
            expenses: expenses,
            progress: _progress,
            workers: number('Total Workers').toInt(),
            skilled: number('Skilled Workers').toInt(),
            floors: number('Number of Floors').toInt(),
            rooms: number('Number of Rooms').toInt(),
            unskilled: number('Unskilled Workers').toInt(),
            labourCost: number('Labour Cost So Far (PKR)'),
            materialCost: number('Material Cost So Far (PKR)'),
            otherExpenses: number('Other Expenses So Far (PKR)'),
            materials: List.unmodifiable(_materials));
    _pendingReport = report;
    setState(() => _saving = true);
    try {
      await context.read<AppState>().saveRiskReport(report);
      if (mounted) setState(() => _report = report);
    } catch (error) {
      if (mounted) message(friendlyError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_report != null) {
      return RiskReportView(
          report: _report!,
          onNew: () => setState(() {
                _report = null;
                _pendingReport = null;
                _step = 0;
              }));
    }
    return SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
      ModuleHeading(
          _step == 0 ? 'Risk Management' : 'Material Inventory',
          _step == 0
              ? 'Enter your construction project details to identify potential project risks.'
              : 'Add the materials currently available at your construction site.'),
      Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text('STEP ${_step + 1} OF 2',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                  Text(
                      _step == 0 ? 'Project Information' : 'Material Inventory',
                      style: const TextStyle(fontSize: 10))
                ]),
            const SizedBox(height: 10),
            LinearProgressIndicator(
                value: (_step + 1) / 2,
                minHeight: 4,
                borderRadius: BorderRadius.circular(8))
          ])),
      if (_step == 0)
        Form(
            key: _form,
            child: Column(children: [
              ModulePanel(
                  title: 'Basic Project Details',
                  icon: Icons.apartment_outlined,
                  children: [
                    field('Project Name'),
                    select(
                        'Project Type',
                        _type,
                        ['Residential', 'Commercial', 'Industrial', 'Other'],
                        (v) => _type = v),
                    field('Location'),
                    pair(
                        field('Number of Floors', numeric: true, integer: true),
                        field('Number of Rooms', numeric: true, integer: true)),
                    pair(
                        field('Project Size', numeric: true),
                        select(
                            'Unit',
                            _unit,
                            ['Marla', 'Kanal', 'Square Feet', 'Square Meters'],
                            (v) => _unit = v)),
                  ]),
              ModulePanel(
                  title: 'Project Timeline',
                  icon: Icons.calendar_month_outlined,
                  children: [
                    pair(dateField('Start Date', _start, true),
                        dateField('Expected Completion', _completion, false))
                  ]),
              ModulePanel(
                  title: 'Budget & Financial Information',
                  icon: Icons.account_balance_wallet_outlined,
                  children: [
                    field('Estimated Budget (PKR)', numeric: true),
                    select(
                        'Current Construction Stage',
                        _stage,
                        [
                          'Foundation',
                          'Grey Structure',
                          'Finishing',
                          'Completed',
                          'Other'
                        ],
                        (v) => _stage = v),
                    Text('Current Progress ${_progress.round()}%',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    Slider(
                        value: _progress,
                        max: 100,
                        divisions: 100,
                        label: '${_progress.round()}%',
                        onChanged: (v) => setState(() => _progress = v)),
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0%', style: TextStyle(fontSize: 10)),
                          Text('100%', style: TextStyle(fontSize: 10))
                        ]),
                    const SizedBox(height: 20),
                    field('Labour Cost So Far (PKR)',
                        numeric: true, optional: true),
                    field('Material Cost So Far (PKR)',
                        numeric: true, optional: true),
                    field('Other Expenses So Far (PKR)',
                        numeric: true, optional: true),
                    Text(
                        'Total Expenses   PKR ${NumberFormat('#,##0').format(expenses)}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ]),
              ModulePanel(
                  title: 'Labour Information',
                  icon: Icons.groups_outlined,
                  children: [
                    field('Total Workers', numeric: true, integer: true),
                    pair(
                        field('Skilled Workers', numeric: true, integer: true),
                        field('Unskilled Workers',
                            numeric: true, integer: true))
                  ]),
              ModulePanel(
                  title: 'Remaining Construction Work',
                  icon: Icons.checklist_rounded,
                  children: [field('Remaining Work', lines: 4)]),
              ModuleButton('Next', onPressed: next),
            ])),
      if (_step == 1) ...[
        if (_materials.isEmpty)
          const ModulePanel(children: [
            Icon(Icons.inventory_2_outlined,
                color: AppColors.textMuted, size: 32),
            SizedBox(height: 12),
            Text('No materials added yet.',
                style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('Add each material currently stored on site.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
          ]),
        for (int i = 0; i < _materials.length; i++)
          ModulePanel(children: [
            Row(children: [
              Expanded(
                  child: Text(_materials[i].name,
                      style: const TextStyle(fontWeight: FontWeight.w800))),
              IconButton(
                  tooltip: 'Edit material',
                  onPressed: _saving ? null : () => editMaterial(i),
                  icon: const Icon(Icons.edit_outlined, size: 18)),
              IconButton(
                  tooltip: 'Remove material',
                  onPressed: _saving
                      ? null
                      : () => setState(() {
                            _pendingReport = null;
                            _materials.removeAt(i);
                          }),
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.danger))
            ]),
            Text(
                '${_materials[i].stock} ${_materials[i].unit} · ${_materials[i].condition}',
                style: const TextStyle(fontSize: 12)),
            if (_materials[i].notes.isNotEmpty)
              Text(_materials[i].notes,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
          ]),
        OutlinedButton.icon(
            onPressed: _saving ? null : () => editMaterial(),
            icon: const Icon(Icons.add),
            label: const Text('Add Material')),
        const SizedBox(height: 20),
        ModuleButton(_saving ? 'Saving report…' : 'Generate Risk Report',
            onPressed: _saving ? null : generate,
            icon: Icons.auto_awesome_outlined),
        TextButton.icon(
            onPressed: _saving ? null : () => setState(() => _step = 0),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back')),
      ],
    ]));
  }
}

class _MaterialDialog extends StatefulWidget {
  final SiteMaterial? material;
  const _MaterialDialog({this.material});
  @override
  State<_MaterialDialog> createState() => _MaterialDialogState();
}

class _MaterialDialogState extends State<_MaterialDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.material?.name);
  late final _stock =
      TextEditingController(text: widget.material?.stock.toString());
  late final _notes = TextEditingController(text: widget.material?.notes);
  late String _unit = widget.material?.unit ?? 'Bags',
      _condition = widget.material?.condition ?? 'Good';
  @override
  void dispose() {
    _name.dispose();
    _stock.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('Add Material'),
          content: SingleChildScrollView(
              child: Form(
                  key: _form,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Enter the current on-site inventory details.',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: _name,
                        decoration:
                            const InputDecoration(labelText: 'Material Name'),
                        validator: (v) =>
                            (v ?? '').trim().isEmpty ? 'Required' : null),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _stock,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Current Stock'),
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          return n == null || !n.isFinite || n < 0
                              ? 'Enter a valid stock quantity'
                              : null;
                        }),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                        initialValue: _unit,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Unit'),
                        items: [
                          'Bags',
                          'Tons',
                          'Kilograms',
                          'Cubic Feet',
                          'Cubic Meters',
                          'Pieces',
                          'Litres',
                          'Bundles',
                          'Other'
                        ]
                            .map((v) =>
                                DropdownMenuItem(value: v, child: Text(v)))
                            .toList(),
                        onChanged: (v) => _unit = v!),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                        initialValue: _condition,
                        isExpanded: true,
                        decoration: const InputDecoration(
                            labelText: 'Material Condition'),
                        items: [
                          'Good',
                          'Damp',
                          'Damaged',
                          'Contaminated',
                          'Poor Quality',
                          'Other',
                          'Not Sure'
                        ]
                            .map((v) =>
                                DropdownMenuItem(value: v, child: Text(v)))
                            .toList(),
                        onChanged: (v) => _condition = v!),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _notes,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            labelText: 'Additional Notes (Optional)')),
                  ]))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    Navigator.pop(
                        context,
                        SiteMaterial(
                            name: _name.text.trim(),
                            stock: double.parse(_stock.text),
                            unit: _unit,
                            condition: _condition,
                            notes: _notes.text.trim()));
                  }
                },
                child: const Text('Save Material'))
          ]);
}

class RiskReportView extends StatelessWidget {
  final RiskAssessment report;
  final VoidCallback? onNew;
  const RiskReportView({super.key, required this.report, this.onNew});
  Color color(String level) => level == 'High'
      ? AppColors.danger
      : level == 'Medium'
          ? AppColors.amber
          : AppColors.success;
  static const actions = [
    'Prepare a detailed cost-to-complete forecast before further procurement.',
    'Create a two-week labour and material look-ahead plan.',
    'Inspect stored materials weekly for moisture, damage and quantity variance.',
    'Hold a short site risk review with trade leads every Monday.'
  ];

  Future<void> export(BuildContext context) async {
    try {
      final doc = pw.Document();
      doc.addPage(pw.MultiPage(
          build: (_) => [
                pw.Header(
                    level: 0,
                    child: pw.Text(
                        'BuildGuard AI - Construction Risk Assessment')),
                pw.Text(
                    'LOCAL PROTOTYPE: heuristic review only; not an AI prediction or regulatory approval.'),
                pw.SizedBox(height: 16),
                pw.Text(report.name,
                    style: const pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    '${report.type} | ${report.location} | ${report.size} ${report.unit}'),
                pw.Text(
                    'Stage: ${report.stage} | Progress: ${report.progress.round()}%'),
                pw.Text(
                    'Target: ${DateFormat('dd MMM yyyy').format(report.completion)} | Overall risk: ${report.level}'),
                pw.Text(
                    'Budget: PKR ${report.budget} | Expenses: PKR ${report.expenses}'),
                pw.Header(level: 1, text: 'Risk Category Overview'),
                for (final c in RiskAssessment.categories)
                  pw.Text('$c: ${report.categoryLevel(c)}'),
                pw.Header(level: 1, text: 'Identified Project Risks'),
                if (report.risks.isEmpty)
                  pw.Text(
                      'No major risk identified from these inputs. This does not establish that the site is safe.'),
                for (final r in report.risks)
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 12),
                        pw.Text('${r.title} (${r.level})',
                            style: const pw.TextStyle(
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text('Reason: ${r.reason}'),
                        pw.Text('Evidence: ${r.evidence}'),
                        pw.Text('Recommended action: ${r.action}')
                      ]),
                pw.Header(level: 1, text: 'Material Inventory'),
                if (report.materials.isEmpty)
                  pw.Text(
                      'No material inventory supplied; material availability has not been assessed.'),
                for (final m in report.materials)
                  pw.Text(
                      '${m.name}: ${m.stock} ${m.unit}, ${m.condition}. ${m.notes}'),
                pw.Header(level: 1, text: 'Recommended Actions'),
                for (final a in actions) pw.Bullet(text: a),
              ]));
      await Printing.sharePdf(
          bytes: await doc.save(), filename: 'buildguard-risk-report.pdf');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not export the report. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: ListView(padding: const EdgeInsets.all(20), children: [
        const Eyebrow('AI Risk Report · Prototype'),
        const SizedBox(height: 10),
        const ModuleHeading('Construction Risk Assessment',
            'Local prototype based on project inputs. Professional review is required.'),
        ModulePanel(
            title: report.name,
            icon: Icons.apartment_outlined,
            children: [
              for (final item in {
                'PROJECT TYPE': report.type,
                'LOCATION': report.location,
                'PROJECT SIZE': '${report.size} ${report.unit}',
                'CURRENT STAGE': report.stage,
                'CURRENT PROGRESS': '${report.progress.round()}%',
                'EXPECTED COMPLETION':
                    DateFormat('dd MMM yyyy').format(report.completion)
              }.entries)
                Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow(item.key),
                          const SizedBox(height: 4),
                          Text(item.value,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600))
                        ])),
            ]),
        Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
                color: color(report.level).withValues(alpha: .07),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: color(report.level).withValues(alpha: .2))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Eyebrow('Overall Project Risk Level'),
              const SizedBox(height: 10),
              Text(report.level,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: color(report.level))),
              const SizedBox(height: 8),
              Text(
                  report.risks.isEmpty
                      ? 'No major risks identified by the prototype rules. This is not a guarantee of site safety.'
                      : report.risks.map((r) => r.category).toSet().join(', '),
                  style: const TextStyle(fontSize: 12, height: 1.6))
            ])),
        ModulePanel(title: 'Risk Category Overview', children: [
          for (final c in RiskAssessment.categories)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Expanded(
                      child: Text(c, style: const TextStyle(fontSize: 12))),
                  const SizedBox(width: 10),
                  Flexible(
                      child: Text(report.categoryLevel(c),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: report.categoryLevel(c) == 'Not assessed'
                                  ? AppColors.textMuted
                                  : color(report.categoryLevel(c)))))
                ]))
        ]),
        const Text('Identified Project Risks',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        for (final r in report.risks)
          Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                  initiallyExpanded: r == report.risks.first,
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text(r.title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  subtitle: Text('${r.category} · ${r.level}',
                      style: TextStyle(fontSize: 10, color: color(r.level))),
                  children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final item in {
                                'Reason for identifying this risk': r.reason,
                                'Evidence from project information': r.evidence,
                                'Recommended solution / preventive action':
                                    r.action
                              }.entries)
                                Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Eyebrow(item.key),
                                          const SizedBox(height: 6),
                                          Text(item.value,
                                              style: const TextStyle(
                                                  fontSize: 12, height: 1.6))
                                        ])),
                            ]))
                  ])),
        if (report.risks.any((r) => r.level == 'High'))
          ModulePanel(
              title: 'Risks Requiring Immediate Attention',
              icon: Icons.warning_amber_rounded,
              children: [
                for (final r in report.risks.where((r) => r.level == 'High'))
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('${r.title}\n${r.action}',
                          style: const TextStyle(fontSize: 12, height: 1.7)))
              ]),
        ModulePanel(title: 'Recommended Actions', children: [
          for (int i = 0; i < actions.length; i++)
            Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primarySoft,
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.primary))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(actions[i],
                              style:
                                  const TextStyle(fontSize: 12, height: 1.6)))
                    ]))
        ]),
        ModuleButton('Download Report as PDF',
            onPressed: () => export(context), icon: Icons.download_outlined),
        if (onNew != null)
          TextButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate New Report')),
      ]));
}
