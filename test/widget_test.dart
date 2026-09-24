import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribbl_io/create_room_screen.dart';
import 'package:skribbl_io/join_room_screen.dart';
import 'package:skribbl_io/main.dart';

void main() {
  testWidgets('home screen shows room actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Create/Join a room to play!'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
    expect(find.text('Join'), findsOneWidget);
  });

  testWidgets('create room screen auto-generates alphanumeric room code', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreateRoomScreen()));

    expect(find.text('AUTO-GENERATED'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
    // Find the dice icon for re-rolling
    expect(find.text('🎲'), findsOneWidget);
  });

  testWidgets('join room screen has paste action and room code field', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: JoinRoomScreen()));

    expect(find.text('PASTE'), findsOneWidget);
    expect(find.text('Join'), findsOneWidget);
  });
}