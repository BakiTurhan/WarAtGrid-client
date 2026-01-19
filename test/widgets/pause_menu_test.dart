import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/overlays/pause_menu.dart';

void main() {
  group('PauseMenuOverlay Widget Tests', () {
    testWidgets('Displays PAUSED title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PauseMenuOverlay(
            onResume: () {},
            onSettings: () {},
            onQuit: () {},
          ),
        ),
      ));

      expect(find.text('PAUSED'), findsOneWidget);
    });

    testWidgets('Displays RESUME button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PauseMenuOverlay(
            onResume: () {},
            onSettings: () {},
            onQuit: () {},
          ),
        ),
      ));

      expect(find.text('RESUME'), findsOneWidget);
    });

    testWidgets('Displays SETTINGS button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PauseMenuOverlay(
            onResume: () {},
            onSettings: () {},
            onQuit: () {},
          ),
        ),
      ));

      expect(find.text('SETTINGS'), findsOneWidget);
    });

    testWidgets('Displays QUIT button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PauseMenuOverlay(
            onResume: () {},
            onSettings: () {},
            onQuit: () {},
          ),
        ),
      ));

      expect(find.text('QUIT'), findsOneWidget);
    });

    testWidgets('RESUME button triggers callback', (WidgetTester tester) async {
      bool resumePressed = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PauseMenuOverlay(
            onResume: () => resumePressed = true,
            onSettings: () {},
            onQuit: () {},
          ),
        ),
      ));

      await tester.tap(find.text('RESUME'));
      await tester.pump();

      expect(resumePressed, true);
    });

    testWidgets('SETTINGS button triggers callback', (WidgetTester tester) async {
      bool settingsPressed = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PauseMenuOverlay(
            onResume: () {},
            onSettings: () => settingsPressed = true,
            onQuit: () {},
          ),
        ),
      ));

      await tester.tap(find.text('SETTINGS'));
      await tester.pump();

      expect(settingsPressed, true);
    });

    testWidgets('QUIT button triggers callback', (WidgetTester tester) async {
      bool quitPressed = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PauseMenuOverlay(
            onResume: () {},
            onSettings: () {},
            onQuit: () => quitPressed = true,
          ),
        ),
      ));

      await tester.tap(find.text('QUIT'));
      await tester.pump();

      expect(quitPressed, true);
    });
  });
}
