import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/screens/menu_screen.dart';

void main() {
  group('MenuScreen Widget Tests', () {
    testWidgets('Displays game title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MenuScreen(onPlay: () {}),
      ));

      expect(find.text('WAR AT GRID'), findsOneWidget);
    });

    testWidgets('Displays subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MenuScreen(onPlay: () {}),
      ));

      expect(find.text('Survive the Grid'), findsOneWidget);
    });

    testWidgets('Displays PLAY button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MenuScreen(onPlay: () {}),
      ));

      expect(find.text('PLAY'), findsOneWidget);
    });

    testWidgets('Displays QUIT button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MenuScreen(onPlay: () {}),
      ));

      expect(find.text('QUIT'), findsOneWidget);
    });

    testWidgets('PLAY button triggers callback', (WidgetTester tester) async {
      bool playPressed = false;

      await tester.pumpWidget(MaterialApp(
        home: MenuScreen(onPlay: () => playPressed = true),
      ));

      await tester.tap(find.text('PLAY'));
      await tester.pump();

      expect(playPressed, true);
    });

    testWidgets('Screen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MenuScreen(onPlay: () {}),
      ));

      expect(find.byType(MenuScreen), findsOneWidget);
    });
  });
}
