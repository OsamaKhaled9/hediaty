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
     final eventArrowButton = find.byKey(Key('event_0')); // Assuming 'event_0' is the first event's key
    expect(eventArrowButton, findsOneWidget);
    await tester.tap(eventArrowButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify Event Details Screen
    final eventDetailsText = find.byKey(Key('eventDetailsText'));
    expect(eventDetailsText, findsOneWidget);


     // Step 7: Scroll and find the Pledge button
  final pledgeButton = find.byKey(Key('PledgeButton'));

  // Wait for the button to appear in the widget tree
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Scroll until the button becomes visible
  await tester.scrollUntilVisible(
    pledgeButton,
    50.0, // Scroll increment
    scrollable: find.byType(Scrollable).first,
  );

  expect(pledgeButton, findsOneWidget); // Ensure the button is present
  await tester.tap(pledgeButton); // Tap the pledge button
  await tester.pumpAndSettle(const Duration(seconds: 5));


      // Go back to Profile
    final backToProfilefromeventButton = find.byTooltip('Back');
    await tester.tap(backToProfilefromeventButton);
    await tester.pumpAndSettle();

    // Step 8: Tap outside to close the modal
    await tester.tapAt(const Offset(0, 0));
    await tester.pumpAndSettle();

    // Step 9: Navigate to Profile
    final profileButton = find.byIcon(Icons.account_circle);
    await tester.tap(profileButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 10: Verify Pledged Gift
    final pledgedGiftsButton = find.widgetWithText(ListTile, 'Pledged Gifts');
    await tester.tap(pledgedGiftsButton);
    await tester.pumpAndSettle();

    final String giftName = 'Ashraf Emulator test 9'; // Replace with the dynamic gift name

    // Check if the pledged gift with the specific name is displayed
    expect(find.text(giftName), findsOneWidget);
    
    // Step 11: Go back to Profile
    final backToProfileButton = find.byTooltip('Back');
    await tester.tap(backToProfileButton);
    await tester.pumpAndSettle();

   // Step 11: Go back to Profile
    final backToHomeButton = find.byTooltip('Back');
    await tester.tap(backToHomeButton);
    await tester.pumpAndSettle();

  });
}
