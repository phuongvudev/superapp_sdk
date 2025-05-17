# How to Exploratory Test Mini Apps

This guide explains how to conduct exploratory testing for mini apps within your SuperAppKit environment. Exploratory testing is a hands-on approach where testers actively explore the application, learning about its features and potential issues through creative investigation rather than following strictly pre-defined test cases.

## Table of Contents
- [Introduction to Exploratory Testing](#introduction-to-exploratory-testing)
- [Preparation for Exploratory Testing](#preparation-for-exploratory-testing)
- [Exploratory Testing Techniques](#exploratory-testing-techniques)
- [Test Session Structure](#test-session-structure)
- [Documentation and Reporting](#documentation-and-reporting)
- [Tools for Exploratory Testing](#tools-for-exploratory-testing)
- [Example Test Charter](#example-test-charter)
- [Best Practices](#best-practices)

## Introduction to Exploratory Testing

Exploratory testing is a simultaneous process of test design and execution where the tester actively controls the design of tests as they are performed and uses the information gained to design new tests. For mini apps, this approach is particularly valuable because:

- It helps identify issues in user flows across app boundaries
- It reveals unexpected behaviors when mini apps interact with the main app
- It uncovers usability issues that structured tests might miss
- It allows for creative discovery of edge cases unique to mini app architecture

## Preparation for Exploratory Testing

### Setting Up the Environment

```dart
// Initialize SuperAppKit for testing
final superApp = await SuperAppKitBuilder()
  .withEnvConfig({'environment': 'staging'})
  .withDebugMode(true)
  .build();

// Register the mini app to be explored
await superApp.miniApp.registerMiniApp(
  MiniAppManifest(
    appId: 'target_mini_app',
    name: 'Target Mini App',
    version: '1.0.0',
    framework: FrameworkType.flutter,
  )
);
```

### Pre-Test Knowledge Gathering

Before starting exploratory testing:

1. **Review Documentation**: Understand the mini app's purpose and intended functionality
2. **Mental Model**: Form a mental model of how the mini app should work within the super app
3. **Risk Assessment**: Identify high-risk areas that deserve more attention
4. **Domain Knowledge**: Gather relevant business domain knowledge for the mini app

## Exploratory Testing Techniques

### 1. Feature Tours

Systematically explore each feature of the mini app:

- Launch and exit flows
- Core functionality
- UI/UX elements
- Navigation patterns
- Integration points with main app
- Data exchanges

### 2. Scenario Testing

Test realistic user scenarios:

- Common user journeys
- Complex workflows
- Edge cases and boundary conditions
- Error conditions and recovery
- Extreme user behaviors

### 3. Domain Testing

Test from the perspective of domain expertise:

- Business rule validation
- Compliance with industry standards
- Domain-specific edge cases
- Business logic correctness

### 4. Interaction Testing

Focus on how the mini app interacts with:

- The main app container
- Other mini apps
- System resources
- Network conditions
- Platform features

## Test Session Structure

Structure your exploratory testing sessions using the Session-Based Test Management approach:

1. **Charter**: Define a clear mission for the test session
2. **Timebox**: Set a specific time limit (typically 60-120 minutes)
3. **Explore**: Conduct the testing, taking notes as you go
4. **Review**: Analyze findings and determine next steps

Example test session charter:
```
CHARTER: Explore payment flow in the Shopping Mini App to discover any issues with 
transaction processing or communication with the main app

AREAS: Payment methods selection, transaction processing, error handling, receipt generation

ENVIRONMENT: Android 12 device, SuperAppKit v1.2.3, Shopping Mini App v1.0.5

SESSION DURATION: 90 minutes
```

## Documentation and Reporting

During exploratory testing, document:

1. **Test Notes**: Record actions taken and observations
2. **Issues Found**: Document bugs with steps to reproduce
3. **Questions Raised**: Note areas of confusion or uncertainty
4. **Testing Coverage**: Track what was tested and what wasn't

Sample test notes format:

```
Time | Action | Observation | Questions/Issues
-----|--------|-------------|------------------
10:05| Launched mini app from main menu | Loaded in 3s with correct theme | None
10:08| Added item to cart | Item appeared in cart but price formatting incorrect | Issue #1: Price shows as 10.0 instead of $10.00
10:12| Attempted checkout with empty shipping address | No validation error shown, allowed to proceed | Issue #2: Missing address validation
```

## Tools for Exploratory Testing

### Bug Reporting Tools

```kotlin
// Example of using a session recording tool in Android
class ExploratoryTestActivity : AppCompatActivity() {
    private lateinit var bugReporter: BugReporter
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize bug reporter with session recording
        bugReporter = BugReporter.Builder(this)
            .enableScreenRecording(true)
            .enableLogCapture(true)
            .setShakeToReport(true)
            .build()
        
        bugReporter.startSession("ExploratoryTestSession_ShoppingApp")
    }
}
```

### Tools for Different Platforms

- **Flutter**: DevTools, Flutter Inspector
- **Android**: Layout Inspector, Logcat
- **iOS**: Xcode Instruments, View Debugger
- **General**: Charles Proxy, Fiddler (for network inspection)

## Example Test Charter

```
TEST CHARTER: Explore Mini App Deep Linking and State Preservation

DURATION: 90 minutes

TESTER: [Your Name]

AREAS TO EXPLORE:
- Deep link navigation to different mini app screens
- State preservation when switching between mini apps
- Behavior when receiving malformed deep links
- Performance under rapid deep link navigation

RISKS:
- State loss when navigating between apps
- Security issues with deep link parameters
- Crash on malformed deep links

TEST DATA:
- Valid deep links: app://mini_app_id/path?param=value
- Invalid deep links: app:///invalid_path, app://unknown_app/path
- Deep links with special characters: app://mini_app_id/path?query=special%20chars+!@#$

APPROACH:
1. Start with valid navigation paths
2. Test state persistence by modifying app state before navigation
3. Try increasingly complex navigation patterns
4. Test error conditions with invalid inputs
```

## Best Practices

1. **Stay Curious**: Maintain an investigative mindset throughout testing

2. **Take Notes**: Document observations in real-time, not just bugs

3. **Use Heuristics**: Apply testing heuristics like HICCUPPSF (History, Image, Comparison, Claims, User, Product, Purpose, Standards, Familiar Problems)

4. **Vary Parameters**: Test with different data, network conditions, and user permissions

5. **Follow Hunches**: When something feels off, investigate further

6. **Pair Testing**: Consider testing with another tester or developer for different perspectives

7. **Time Management**: Use timeboxes to ensure broad coverage rather than getting stuck

8. **Retrospective**: After each session, reflect on what you learned and how to improve

9. **Cross-Platform Testing**: Test the same mini app on different platforms to find platform-specific issues

10. **Evolve Your Approach**: Use what you learn to inform future test sessions

Exploratory testing complements structured testing approaches by finding issues that predefined test cases might miss. For mini apps specifically, focus on transitions between apps, data sharing, and the overall user experience flow to uncover the most critical issues.