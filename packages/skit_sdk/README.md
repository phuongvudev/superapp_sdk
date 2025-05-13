# SKIT SDK Package

The `SKIT SDK` package provides the foundational building blocks for our Flutter mini-app ecosystem. It contains essential services, models, and utilities used across all mini-apps and the host application.

## Overview

This package is designed to be a centralized location for:

*   **Data Models:** Defining the core data structures used throughout the application (e.g., `User`, `MiniAppManifest`).
*   **Services:** Providing essential services like authentication, deep link handling, and mini-app launching.
*   **Communication:** Facilitating communication between different parts of the application, including the use of an `EventBus`.
*   **Constants:** Defining common constants and enumerations.
*   **Logging:** Providing a centralized logger for all parts of the core.
*   **SDK Initialization**: Initialize all the feature.

## Key Features

### 1. Mini-App Manifest

The `MiniAppManifest` (`src/manifest/mini_app_manifest.dart`) defines the metadata for each mini-app. This includes:

*   `appId`: A unique identifier for the mini-app.
*   `name`: The display name of the mini-app.
*   `framework`: The framework used by the mini-app (e.g., Flutter, React Native).
*   `entryPath`: The entry point of the mini-app.
*   `deepLinks`: A list of deep links that the mini-app can handle.

### 2. Deep Link Handling

The `DeepLinkDispatcher` (`src/communication/external_communication/deep_link_dispatcher.dart`) handles the deep link routing to the appropriate mini-app. Key components:

*   **`DeepLinkDispatcher`**: Responsible for listening to incoming deep links and dispatching them to the correct mini-app.
*   **`DeepLinkMatcher`**: Contains the logic for matching deep links against the patterns defined in the `MiniAppManifest`.

### 3. Authentication Service

The `AuthenticationService` (`src/services/authentication/authentication_service.dart`) manages user authentication. It supports multiple authentication methods through the `AuthenticationMethod` abstraction:

*   **`AuthenticationService`**: Handles user login, logout, and storage of the current user.
*   **`AuthenticationMethod`**: An interface for different authentication mechanisms (e.g., username/password, SSO).
*   **`AccountAuthenticationMethod`**:  An implementation for account authentication.
*   **`User`**: A data model for the authenticated user.

### 4. Mini-App Launcher

The `MiniAppKit` (`src/services/mini_app/mini_app_launcher.dart`) is responsible for launching mini-apps based on their manifests.

### 5. Event Bus

The `EventBus` (`src/communication/event_bus.dart`) facilitates communication between different parts of the application. It allows components to:

*   **Dispatch Events:** Emit events.
*   **Listen to Events:** Receive and react to events.

Example of Authentication Event:
`src/communication/events/authentication_events.dart`

### 6. Logger
The logger (`src/logger/logger.dart`) is responsible for adding log.

### 7. SDK Initializer
The `sdk_initializer.dart` is the entry point for all the feature of the core module.

### 8. Other Utilities

The `core` package may also contain other utility classes, helper functions, and data models used across multiple mini-apps.

## Getting Started

### Installation

To use the `core` package, add it as a dependency to your `pubspec.yaml` file:

Then, run `flutter pub get`.

### Usage

1. **Initialize:** Use `SdkInitializer` to initialize the package.
2. **Authentication** : Initialize `AuthenticationService` and use it.
3. **Deep Link** : Initialize `DeepLinkDispatcher` and use it.
4. **EventBus**: You can use the event bus for dispatch and receive events.
5. **Logger**: Use it to add log.

## Contributing

Contributions to the `skit_sdk` package are welcome! Please follow these guidelines:

1.  Fork the repository.
2.  Create a new branch for your feature or bug fix.
3.  Write clear and concise commit messages.
4.  Submit a pull request with a detailed description of your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.