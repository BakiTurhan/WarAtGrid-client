import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/screens/settings_screen.dart';
import 'package:waratgrid/config.dart';

void main() {
  setUp(() {
    cfg.resetToDefaults();
  });

  group('SettingsScreen Widget Tests', () {
    testWidgets('Displays SETTINGS title', (WidgetTester tester) async {
      // Use larger viewport to avoid overflow
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(MaterialApp(
        home: SettingsScreen(onBack: () {}),
      ));

      expect(find.text('SETTINGS'), findsOneWidget);

      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('Displays category buttons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(MaterialApp(
        home: SettingsScreen(onBack: () {}),
      ));

      expect(find.text('PLAYER'), findsOneWidget);
      expect(find.text('COMBAT'), findsOneWidget);
      expect(find.text('WEAPONS'), findsOneWidget);
      expect(find.text('ENEMY'), findsOneWidget);
      expect(find.text('WORLD'), findsOneWidget);

      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('Displays BACK button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(MaterialApp(
        home: SettingsScreen(onBack: () {}),
      ));

      expect(find.text('BACK'), findsOneWidget);

      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('Displays RESET button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(MaterialApp(
        home: SettingsScreen(onBack: () {}),
      ));

      expect(find.text('RESET'), findsOneWidget);

      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('BACK button triggers callback', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      bool backPressed = false;

      await tester.pumpWidget(MaterialApp(
        home: SettingsScreen(onBack: () => backPressed = true),
      ));

      await tester.tap(find.text('BACK'));
      await tester.pump();

      expect(backPressed, true);

      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('Category buttons change active section', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(MaterialApp(
        home: SettingsScreen(onBack: () {}),
      ));

      // Tap COMBAT category
      await tester.tap(find.text('COMBAT'));
      await tester.pump();

      // Should show combat-related settings
      expect(find.text('Dash Distance'), findsOneWidget);

      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('PLAYER section shows player settings', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(MaterialApp(
        home: SettingsScreen(onBack: () {}),
      ));

      // PLAYER is default active section
      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);

      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('Sliders are present', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(MaterialApp(
        home: SettingsScreen(onBack: () {}),
      ));

      expect(find.byType(Slider), findsWidgets);

      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('RESET button resets config values', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      // Modify a value
      cfg.playerSpeed = 999.0;

      await tester.pumpWidget(MaterialApp(
        home: SettingsScreen(onBack: () {}),
      ));

      // Tap RESET
      await tester.tap(find.text('RESET'));
      await tester.pump();

      // Value should be reset
      expect(cfg.playerSpeed, 200.0);

      addTearDown(() => tester.view.resetPhysicalSize());
    });
  });
}
