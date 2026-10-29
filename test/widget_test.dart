import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:veylora/main.dart';
import 'package:veylora/codes/collection_pages.dart';

void main() {
  testWidgets('shows the personalized login screen UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome to Veylora'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('navigates from login to the wardrobe dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('What are you wearing today?'), findsOneWidget);

    await tester.tap(find.byTooltip('Account details'));
    await tester.pumpAndSettle();
    expect(find.text('Your profile'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Services'));
    await tester.pumpAndSettle();
    expect(find.text('Style services'), findsNWidgets(2));
    await tester.tap(find.text('Style consultation'));
    await tester.pumpAndSettle();
    expect(find.text('Find your next favorite look.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wardrobe'));
    await tester.pumpAndSettle();
    expect(find.text('Your collection'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
    expect(find.byType(ListTile), findsWidgets);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDrawer), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Your preferences'), findsOneWidget);
    expect(find.text('Style reminders'), findsOneWidget);
    await tester.tap(find.text('Account details'));
    await tester.pumpAndSettle();
    expect(find.text('Your profile'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy and security'));
    await tester.pumpAndSettle();
    expect(find.text('Your privacy matters'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('My wardrobe').last);
    await tester.pumpAndSettle();

    expect(find.text('Your collection'), findsOneWidget);
    expect(find.text('Add item'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.text('Everyday essentials'));
    await tester.pumpAndSettle();
    expect(find.text('Linen overshirt'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved products'));
    await tester.pumpAndSettle();
    expect(find.text('Everyday knit'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    expect(find.text('Add wardrobe item'), findsOneWidget);
  });

  testWidgets('validates and completes a card payment', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PaymentPage()));

    await tester.tap(find.text('Pay now'));
    await tester.pump();
    expect(find.text('Enter an amount greater than zero'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '49.99');
    await tester.enterText(fields.at(1), '4242424242424242');
    await tester.enterText(fields.at(2), '12/29');
    await tester.enterText(fields.at(3), '123');
    await tester.tap(find.text('Pay now'));
    await tester.pumpAndSettle();

    expect(find.text('Payment received'), findsOneWidget);
    expect(find.text('₱49.99 was paid with Card.'), findsOneWidget);
  });
}
