import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildguard_ai/main.dart';
import 'package:buildguard_ai/screens/home_shell.dart';
import 'package:buildguard_ai/screens/risk_management_tab.dart';
import 'package:buildguard_ai/state/app_state.dart';
import 'package:buildguard_ai/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
      'Project inputs and inventory generate a saved, expandable report',
      (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = AppState();
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: RiskManagementTab()))));

    Future<void> fill(String label, String value) async {
      final target = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == label);
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.enterText(target, value);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    }

    for (final item in {
      'Project Name': 'Test House',
      'Location': 'Lahore',
      'Number of Floors': '2',
      'Number of Rooms': '12',
      'Project Size': '10',
      'Estimated Budget (PKR)': '8500000',
      'Labour Cost So Far (PKR)': '1700000',
      'Material Cost So Far (PKR)': '3800000',
      'Other Expenses So Far (PKR)': '600000',
      'Total Workers': '12',
      'Skilled Workers': '4',
      'Unskilled Workers': '8',
      'Remaining Work': 'Roof and finishing'
    }.entries) {
      await fill(item.key, item.value);
    }
    Future<void> date(String label, String value) async {
      final target = find
          .ancestor(of: find.text(label), matching: find.byType(InkWell))
          .first;
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Switch to input'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, value);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    await date('Start Date', '06/01/2026');
    await date('Expected Completion', '02/28/2027');
    await tester.ensureVisible(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('STEP 2 OF 2'), findsOneWidget);
    await tester.tap(find.text('Add Material'));
    await tester.pumpAndSettle();
    await fill('Material Name', 'Cement');
    await fill('Current Stock', '0');
    await tester.tap(find.text('Save Material'));
    await tester.pumpAndSettle();
    expect(find.text('Cement'), findsOneWidget);
    await tester.ensureVisible(find.text('Generate Risk Report'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate Risk Report'));
    await tester.pumpAndSettle();
    expect(find.text('Construction Risk Assessment'), findsOneWidget);
    expect(state.riskReports.single.name, 'Test House');
    expect(state.riskReports.single.materials.single.name, 'Cement');
    expect(
        state.riskReports.single.categoryLevel('Material Shortages'), 'High');
    await tester.scrollUntilVisible(find.text('Download Report as PDF'), 400,
        scrollable: find
            .descendant(
                of: find.byType(RiskReportView),
                matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    expect(find.text('Download Report as PDF'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Landing fits a narrow phone and Login opens the form',
      (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BuildGuardApp());
    expect(find.text('Our Core Features'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Login').first);
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Home opens Risk, validates empty input, and retains tab state',
      (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(theme: AppTheme.light, home: const HomeShell())));
    expect(find.text('Welcome Back!'), findsOneWidget);
    await tester.ensureVisible(find.text('Open Risk Management'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Risk Management'));
    await tester.pumpAndSettle();
    expect(find.text('Basic Project Details'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'My house');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsWidgets);
    expect(find.text('Material Inventory'), findsNothing);
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Risk').last);
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate(
            (w) => w is TextFormField && w.controller?.text == 'My house'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Risk form renders at phone width', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: RiskManagementTab()))));
    expect(find.text('STEP 1 OF 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
