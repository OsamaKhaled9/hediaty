import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hediaty/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Friend Event Gift Pledge Test', (WidgetTester tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 1: Navigate to Sign In
    final signInTextButton = find.byKey(Key('alreadyHaveAccountButton'));
    expect(signInTextButton, findsOneWidget);
    await tester.tap(signInTextButton);
    await tester.pumpAndSettle();

    // Step 2: Enter Email and Password
    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final signInButton = find.byKey(Key('signInButton'));

    await tester.enterText(emailField, 'x@example.com');
    await tester.enterText(passwordField, '123456789');
    await tester.tapAt(const Offset(0, 0)); // Dismiss keyboard
    await tester.pumpAndSettle();

    // Step 3: Log In
    await tester.tap(signInButton);
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Step 4: Verify Home Screen
    expect(find.text('Hello, sama!'), findsOneWidget);

    // Step 5: Click the > button of the first friend
    final friendArrowButton = find.byIcon(Icons.arrow_forward_ios).first;
    await tester.scrollUntilVisible(friendArrowButton, 50.0); // Ensure it's visible
    await tester.tap(friendArrowButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 6: View Event Details
   final eventArrowButton = find.byType(ListTile).first; // Assuming ListTile is used for events
    await tester.tap(eventArrowButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify Event Details Screen
    expect(find.byKey(Key('eventDetailsText')), findsOneWidget);

    // Step 7: Pledge a Gift
    final pledgeButton = find.widgetWithText(ElevatedButton, 'Pledge').first;
    await tester.tap(pledgeButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 8: Tap outside to close the modal
    await tester.tapAt(const Offset(0, 0));
    await tester.pumpAndSettle();

    // Step 9: Navigate to Profile
    final profileButton = find.byIcon(Icons.person);
    await tester.tap(profileButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 10: Verify Pledged Gift
    final pledgedGiftsButton = find.widgetWithText(ListTile, 'My Pledged Gifts');
    await tester.tap(pledgedGiftsButton);
    await tester.pumpAndSettle();

    // Check if the pledged gift is displayed
    expect(find.text('Gift Name'), findsOneWidget);

    // Step 11: Go back to Profile
    final backToProfileButton = find.byTooltip('Back');
    await tester.tap(backToProfileButton);
    await tester.pumpAndSettle();

    // Step 12: Go back to Home
    final homeButton = find.byIcon(Icons.home);
    await tester.tap(homeButton);
    await tester.pumpAndSettle();
  });
}
