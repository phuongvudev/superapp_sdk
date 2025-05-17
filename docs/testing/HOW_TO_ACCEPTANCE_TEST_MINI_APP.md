# How to Acceptance Test Mini Apps

This guide outlines the process for conducting acceptance testing on mini apps within your SuperAppKit environment. Follow these steps to ensure your mini apps meet business requirements before deploying to production.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Setting Up Test Environment](#setting-up-test-environment)
- [Acceptance Testing Process](#acceptance-testing-process)
- [Test Case Development](#test-case-development)
- [Execution and Validation](#execution-and-validation)
- [Common Issues and Solutions](#common-issues-and-solutions)

## Prerequisites

Before beginning acceptance testing:

- Complete mini app implementation
- Documentation of requirements and expected behaviors
- Access to test environments
- Test user accounts with appropriate permissions

## Setting Up Test Environment

### Configure SuperAppKit for Testing

```dart
// Initialize SuperAppKit with test configuration
final superApp = await SuperAppKitBuilder()
  .withEnvConfig({
    'environment': 'staging',
    'apiEndpoint': 'https://api-staging.example.com',
  })
  .withDebugMode(true)
  .build();
```

### Create Test Configuration

```dart
// Configure test settings
final testConfig = TestConfiguration(
  environment: 'staging',
  logLevel: LogLevel.verbose,
  mockServices: false,
);
```

### Register Mini App for Testing

```dart
// Register mini app with test parameters
final manifest = MiniAppManifest(
  appId: 'test_mini_app',
  name: 'Test Mini App',
  version: '1.0.0',
  framework: FrameworkType.flutter,
  entryPath: 'com.example.testminiapp.MainActivity',
  params: {'testMode': 'true', 'testUser': 'tester123'},
  appBuilder: (params) => TestMiniAppRoot(params: params),
);

await superApp.miniApp.registerMiniApp(manifest);
```

## Acceptance Testing Process

1. **Requirement Review**: Ensure you understand the mini app's business requirements and acceptance criteria

2. **Environment Setup**: Configure the testing environment based on the mini app's needs

3. **Test Case Planning**: Create test cases covering all required functionality

4. **Test Execution**: Follow the test cases and record results

5. **Defect Management**: Document and track any issues found

6. **Regression Testing**: Verify fixes don't introduce new problems

7. **Final Approval**: Obtain stakeholder sign-off

## Test Case Development

Structure your test cases using the following format:

```
Test ID: AC-001
Title: Mini App Launch and Authentication
Preconditions: 
  - SuperAppKit initialized in test environment
  - Test user credentials available
Steps:
  1. Register mini app with test parameters
  2. Launch mini app with valid user authentication
  3. Verify mini app loads with correct user context
  4. Complete a key user journey (e.g., view account details)
Expected Result: 
  - Mini app launches successfully
  - User information correctly displayed
  - All navigation elements work as expected
```

## Execution and Validation

### Launch and Verify Mini App

```dart
Future<void> testMiniAppLaunch() async {
  // Arrange
  final testParams = {'userId': 'test123', 'feature': 'premium'};
  
  // Act
  try {
    final result = await superApp.miniApp.launch('test_mini_app', params: testParams);
    
    // Assert
    expect(result.isSuccess, true);
    expect(result.data['userProfile'], isNotNull);
    
    print('✅ Mini app launch test passed');
  } catch (e) {
    print('❌ Mini app launch test failed: $e');
    rethrow;
  }
}
```

### Test Deep Link Handling

```dart
Future<void> testMiniAppDeepLink() async {
  // Arrange
  final deepLink = 'app://test_mini_app/profile?id=12345';
  
  // Act
  final result = await superApp.deepLink.handleLink(deepLink);
  
  // Assert
  expect(result.handled, true);
  expect(result.miniAppId, 'test_mini_app');
  expect(result.path, '/profile');
}
```

### Validate Event Communication

```dart
Future<void> testMiniAppEvents() async {
  // Arrange
  bool eventReceived = false;
  superApp.eventBus.on('test_event', (data) {
    eventReceived = true;
  });
  
  // Act
  await superApp.eventBus.emit('test_event', {'status': 'success'});
  
  // Assert
  expect(eventReceived, true);
}
```

## Common Issues and Solutions

| Issue | Possible Cause | Solution |
|-------|----------------|----------|
| Mini app fails to launch | Incorrect entry path | Verify the entryPath in MiniAppManifest |
| Missing appBuilder | Flutter mini app without builder | Add appBuilder function to MiniAppManifest |
| Communication failures | Event bus initialization issue | Check eventBus configuration in SuperAppKit |
| Inconsistent UI | Parameter passing issues | Verify params are correctly passed in launch method |
| Data not available | Missing or invalid environment config | Check environment configuration in SuperAppKitBuilder |

Remember to test on actual devices when possible and verify behavior across different network conditions. Document all test results for future reference and continuous improvement.