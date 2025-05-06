# Main App Architecture Documentation

## Overview

The Main App serves as the host platform for various mini applications, creating a unified ecosystem while maintaining modularity. This architecture allows for independent development of features as mini apps while providing a cohesive user experience.

## Architecture Components

### 1. Core Framework

- **Core Module**: Central package managing shared functionality
- **Platform Bridge**: Native code integration for iOS and Android
- **Event Communication**: Bidirectional messaging system between main app and mini apps

### 2. App Structure

```
main_app/
├── core/              # Core functionality and shared services
├── mini_app_host/     # Containers for mini app integration
├── navigation/        # Navigation and routing system
├── state_management/  # Global state management
├── ui_components/     # Shared UI components
└── services/          # App-wide services
```

## Communication Architecture

### Event Bus Pattern

The Event Bus forms the backbone of the communication system between the Main App and Mini Apps:

- **Bidirectional Messaging**: Events flow in both directions
- **Type-Safe Events**: Structured event types with defined schemas
- **Secure Communication**: Optional encryption for sensitive data
- **Cross-Platform Support**: Native implementation on iOS and Android

### Implementation Details

- Flutter's MethodChannel and EventChannel for native platform communication
- Broadcast streams for in-app event distribution
- Support for encrypted and unencrypted messages

## Mini App Integration

### Supported Mini App Types

- **Native Flutter**: Direct integration with shared event bus
- **WebView-Based**: Web applications with JavaScript bridge
- **React Native**: Integration via native modules and event emitters
- **Native Platform Views**: Android/iOS native views with bidirectional communication

### Mini App Lifecycle

1. Registration with the main app
2. Initialization and configuration
3. Active communication via event bus
4. Cleanup and resource release

## Security Considerations

- End-to-end encryption for sensitive communications
- Platform-specific security implementations
- Validation of event data and sources

## Development Guidelines

### Best Practices

- Use typed events for better compile-time safety
- Implement proper error handling for all communications
- Test cross-platform compatibility thoroughly
- Document all event types and their payload structures

### Debugging and Testing

- Enable verbose logging in development builds
- Use the visual event monitor for debugging
- Create comprehensive test events for communication paths

## Deployment Model

- Main App provides the shell and core services
- Mini Apps can be updated independently
- Configuration-driven feature flags for gradual rollouts

This architecture enables a flexible, modular approach to app development while maintaining a cohesive experience for users.