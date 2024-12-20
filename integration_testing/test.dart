// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:project_hedieaty/main.dart';
// import 'package:flutter/material.dart';
//
// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
//
//   group('End-to-End Integration Tests', () {
//     testWidgets('Create account, login, manage events and gifts', (tester) async {
//       // Start the app
//       await tester.pumpWidget(MyApp()); // Use the main app widget here
//       await tester.pumpAndSettle();
//
//       // Step 1: Sign up
//       expect(find.text('Sign Up'), findsOneWidget);
//       await tester.enterText(find.byKey(Key('signup_name')), 'Test User');
//       await tester.enterText(find.byKey(Key('signup_phone')), '1234567890');
//       await tester.enterText(find.byKey(Key('signup_email')), 'test@example.com');
//       await tester.enterText(find.byKey(Key('signup_birthday')), '2000-01-01');
//       await tester.enterText(find.byKey(Key('signup_password')), 'password123');
//       await tester.tap(find.byKey(Key('signup_button')));
//       await tester.pumpAndSettle();
//
//       // Verify user navigates to login
//       expect(find.text('Log In'), findsOneWidget);
//
//       // Step 2: Log in
//       await tester.enterText(find.byKey(Key('login_email')), 'test@example.com');
//       await tester.enterText(find.byKey(Key('login_password')), 'password123');
//       await tester.tap(find.byKey(Key('login_button')));
//       await tester.pumpAndSettle();
//
//       // Verify home screen
//       expect(find.text('Hedieaty - Home Page'), findsOneWidget);
//
//       // Step 3: Add a friend by username
//       await tester.tap(find.byIcon(Icons.add));
//       await tester.pumpAndSettle();
//       await tester.enterText(find.byKey(Key('add_friend_username')), 'friendUser');
//       await tester.tap(find.byKey(Key('add_friend_button')));
//       await tester.pumpAndSettle();
//
//       // Verify friend added
//       expect(find.text('friendUser'), findsOneWidget);
//
//       // Step 4: Create a new event
//       await tester.tap(find.byKey(Key('add_event_button')));
//       await tester.pumpAndSettle();
//       await tester.enterText(find.byKey(Key('event_name')), 'Birthday Party');
//       await tester.enterText(find.byKey(Key('event_location')), 'Home');
//       await tester.enterText(find.byKey(Key('event_date')), '2024-12-31');
//       await tester.tap(find.byKey(Key('save_event_button')));
//       await tester.pumpAndSettle();
//
//       // Verify event created
//       expect(find.text('Birthday Party'), findsOneWidget);
//
//       // Step 5: Add a gift to the event
//       await tester.tap(find.byKey(Key('add_gift_button')));
//       await tester.pumpAndSettle();
//       await tester.enterText(find.byKey(Key('gift_name')), 'Watch');
//       await tester.enterText(find.byKey(Key('gift_category')), 'Accessories');
//       await tester.enterText(find.byKey(Key('gift_price')), '100');
//       await tester.tap(find.byKey(Key('save_gift_button')));
//       await tester.pumpAndSettle();
//
//       // Verify gift added
//       expect(find.text('Watch'), findsOneWidget);
//
//       // Step 6: Pledge a gift
//       await tester.tap(find.text('Watch'));
//       await tester.tap(find.byKey(Key('pledge_button')));
//       await tester.pumpAndSettle();
//
//       // Verify pledge
//       expect(find.byKey(Key('gift_status_pledged')), findsOneWidget);
//
//       // Step 7: Sort gifts by name
//       await tester.tap(find.byIcon(Icons.sort));
//       await tester.tap(find.text('Sort by Name'));
//       await tester.pumpAndSettle();
//
//       // Verify sorting
//       expect(find.text('Watch'), findsWidgets);
//
//       // Step 8: View profile and logout
//       await tester.tap(find.byIcon(Icons.person));
//       await tester.pumpAndSettle();
//       await tester.tap(find.byKey(Key('logout_button')));
//       await tester.pumpAndSettle();
//
//       // Verify returned to login
//       expect(find.text('Log In'), findsOneWidget);
//     });
//   });
// }
