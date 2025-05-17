# How to End-to-End Test Mini Apps

This guide explains how to perform end-to-end testing for mini apps within your SuperAppKit environment. End-to-end testing validates the complete flow of your mini app in integration with the main application, simulating real user journeys.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Setting Up End-to-End Test Environment](#setting-up-end-to-end-test-environment)
- [Test Strategy](#test-strategy)
- [Creating End-to-End Test Cases](#creating-end-to-end-test-cases)
- [Testing Tools and Frameworks](#testing-tools-and-frameworks)
- [Implementation Examples](#implementation-examples)
- [Common Issues and Solutions](#common-issues-and-solutions)
- [Best Practices](#best-practices)

## Prerequisites

Before starting end-to-end testing:

- Complete mini app development
- Functioning SuperAppKit integration
- Real or simulated backend services
- Test devices or emulators
- Test user accounts with appropriate permissions

## Setting Up End-to-End Test Environment

### Configure SuperAppKit for E2E Testing

```dart
// Initialize SuperAppKit with end-to-end testing configuration
final superApp = await SuperAppKitBuilder()
  .withEnvConfig({
    'environment': 'e2e_test',
    'apiEndpoint': 'https://api-e2e.example.com',
  })
  .withDebugMode(true)
  .build();
```

### Register Test Mini Apps

```dart
// Register all mini apps needed for end-to-end scenarios
final testMiniApp = MiniAppManifest(
  appId: 'payment_mini_app',
  name: 'Payment Mini App',
  version: '1.0.0',
  framework: FrameworkType.flutter,
  entryPath: 'com.example.payment.MainActivity',
  params: {'testMode': 'true'},
  appBuilder: (params) => PaymentMiniApp(params: params),
);

await superApp.miniApp.registerMiniApp(testMiniApp);
```

## Test Strategy

End-to-end testing should validate:

1. **Complete User Journeys**: Test entire flows from start to finish
2. **Integration Points**: Verify communication between mini app and main app
3. **Navigation Flows**: Test transitions between screens and apps
4. **Data Persistence**: Verify data is maintained across the journey
5. **Error Handling**: Test recovery from errors and edge cases

## Creating End-to-End Test Cases

Structure test cases to cover complete user journeys:

```
Test ID: E2E-001
Title: Complete Payment Flow with Mini App
Preconditions:
  - User is logged in to main app
  - User has items in cart
  - Payment mini app is registered
Steps:
  1. Navigate to checkout in main app
  2. Launch payment mini app
  3. Select payment method
  4. Enter payment details
  5. Submit payment
  6. Return to main app
  7. Verify order confirmation
Expected Results:
  - Payment mini app launches correctly
  - Payment processes successfully
  - User returns to main app with confirmed order
  - Order appears in user history
```

## Testing Tools and Frameworks

### Flutter/Dart

```dart
// Using integration_test package
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('End-to-end payment flow test', (WidgetTester tester) async {
    // Start with main app
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    
    // Navigate to checkout
    await tester.tap(find.byKey(Key('checkout_button')));
    await tester.pumpAndSettle();
    
    // Launch mini app
    await tester.tap(find.byKey(Key('launch_payment_app')));
    await tester.pumpAndSettle();
    
    // Complete payment flow
    await tester.enterText(find.byKey(Key('card_number')), '4111111111111111');
    await tester.enterText(find.byKey(Key('expiry')), '12/25');
    await tester.tap(find.byKey(Key('submit_payment')));
    await tester.pumpAndSettle();
    
    // Verify success
    expect(find.text('Payment Successful'), findsOneWidget);
    expect(find.text('Order #12345 Confirmed'), findsOneWidget);
  });
}
```

### Native Android (Kotlin/Java)

```kotlin
// Using Espresso for Android testing
@RunWith(AndroidJUnit4::class)
class PaymentMiniAppE2ETest {
    @Rule
    @JvmField
    val activityRule = ActivityScenarioRule(MainActivity::class.java)
    
    @Test
    fun completePaymentFlow() {
        // Navigate to checkout
        onView(withId(R.id.checkout_button)).perform(click())
        
        // Launch mini app
        onView(withId(R.id.launch_payment_app)).perform(click())
        
        // Complete payment flow
        onView(withId(R.id.card_number)).perform(typeText("4111111111111111"))
        onView(withId(R.id.expiry)).perform(typeText("12/25"))
        onView(withId(R.id.submit_payment)).perform(click())
        
        // Verify success
        onView(withText("Payment Successful")).check(matches(isDisplayed()))
        onView(withText(containsString("Order #"))).check(matches(isDisplayed()))
    }
}
```

## Implementation Examples

### Testing Deep Link Navigation

```dart
Future<void> testDeepLinkFlow() async {
  // Arrange: Set up deep link
  final deepLink = 'app://payment_mini_app/checkout?amount=99.99&currency=USD';
  
  // Act: Trigger deep link
  final result = await superApp.deepLink.handleLink(deepLink);
  
  // Assert: Verify correct handling
  expect(result.handled, true);
  expect(result.miniAppId, 'payment_mini_app');
  
  // Complete the payment flow
  await tester.tap(find.byKey(Key('confirm_payment')));
  await tester.pumpAndSettle();
  
  // Verify return to main app
  expect(find.text('Order Confirmed'), findsOneWidget);
}
```

### Testing Inter-Mini-App Communication

```dart
Future<void> testInterAppCommunication() async {
  // Arrange: Set up event listener 
  bool eventReceived = false;
  superApp.eventBus.on('payment_completed', (data) {
    eventReceived = true;
  });
  
  // Act: Launch first mini app
  await superApp.miniApp.launch('shopping_mini_app');
  await tester.pumpAndSettle();
  
  // Complete purchase flow
  await tester.tap(find.byKey(Key('buy_now')));
  await tester.pumpAndSettle();
  
  // Should automatically launch payment mini app
  expect(find.text('Payment Details'), findsOneWidget);
  
  // Complete payment
  await tester.tap(find.byKey(Key('pay_now')));
  await tester.pumpAndSettle();
  
  // Assert: Verify communication occurred
  expect(eventReceived, true);
  
  // Verify return to shopping app with confirmation
  expect(find.text('Purchase Complete'), findsOneWidget);
}
```

## Common Issues and Solutions

| Issue | Possible Cause | Solution |
|-------|----------------|----------|
| Test fails at mini app transition | Timing issues | Add appropriate waiting mechanisms or increase timeouts |
| Deep links not triggering | Configuration issues | Verify deep link scheme registration in both manifest and SuperAppKit |
| Events not being received | EventBus initialization | Ensure event listeners are registered before events are triggered |
| UI elements not found | Screen rendering delays | Use `pumpAndSettle()` or explicit waits before assertions |
| Mini app crashes during test | Resource issues | Check for memory leaks, implement proper cleanup in tests |
| Inconsistent results | State persistence between tests | Reset app state between test runs |

## Best Practices

1. **Test Real User Journeys**: Focus on testing complete flows that users will actually follow

2. **Isolate Tests**: Ensure each test can run independently without depending on other tests

3. **Handle Asynchronous Operations**: Use proper waiting mechanisms for network calls and animations

4. **Test on Multiple Devices**: Verify behavior across different screen sizes and OS versions

5. **Mock External Dependencies**: Use mock servers for APIs to ensure test stability

6. **Record Test Videos**: Configure test runs to record videos for easier debugging

7. **Implement Reporting**: Generate detailed reports of test results for traceability

8. **Maintain Test Data**: Create dedicated test accounts and consistent test data

9. **Monitor Performance**: Track key performance metrics during end-to-end tests

10. **Run Tests Regularly**: Integrate end-to-end tests into your CI/CD pipeline

Remember that end-to-end tests are valuable but expensive to maintain. Focus on covering the most critical user journeys rather than trying to test everything.