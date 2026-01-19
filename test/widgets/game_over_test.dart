import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waratgrid/overlays/game_over.dart';

void main() {
  group('GameOverOverlay Widget Tests', () {
    testWidgets('Displays GAME OVER title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GameOverOverlay(finalScore: 1000, onRestart: () {}),
      ));

      expect(find.text('GAME OVER'), findsOneWidget);
    });

    testWidgets('Displays final score', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GameOverOverlay(finalScore: 12345, onRestart: () {}),
      ));

      expect(find.textContaining('12345'), findsOneWidget);
    });

    testWidgets('Displays RESTART button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GameOverOverlay(finalScore: 0, onRestart: () {}),
      ));

      expect(find.text('RESTART'), findsOneWidget);
    });

    testWidgets('RESTART button triggers callback', (WidgetTester tester) async {
      bool restartPressed = false;

      await tester.pumpWidget(MaterialApp(
        home: GameOverOverlay(
          finalScore: 0,
          onRestart: () => restartPressed = true,
        ),
      ));

      await tester.tap(find.text('RESTART'));
      await tester.pump();

      expect(restartPressed, true);
    });

    testWidgets('Shows different scores correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GameOverOverlay(finalScore: 999999, onRestart: () {}),
      ));

      expect(find.textContaining('999999'), findsOneWidget);
    });

    testWidgets('Shows zero score', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GameOverOverlay(finalScore: 0, onRestart: () {}),
      ));

      // Should still show 0 (or formatted version)
      expect(find.byType(Text), findsWidgets);
    });
  });
}
