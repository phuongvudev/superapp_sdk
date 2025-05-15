# Documentation Summary

This document provides an organized overview of all documentation files in the project, grouped by topic.

## [Core Architecture](docs/core_architecture/README.md)

Documentation covering the fundamental architecture of the main application and mini app ecosystem.

| File | Description | Link | Status |
|------|-------------|------|--------|
| Main App Architecture | Explains the host platform architecture, benefits of Flutter, and key features | [View](docs/core_architecture/MAIN_APP.md) | Completed |
| Mini App Architecture | Overview of mini app concepts, supported frameworks, and lifecycle management | [View](docs/core_architecture/MINI_APP.md) | Completed |

## [Mini App Guides](docs/mini_app_guides/README.md)

Step-by-step guides for creating and integrating mini apps using different technologies.

| File | Description | Link | Status |
|------|-------------|------|--------|
| Flutter Mini App Guide | How to create, integrate, and launch Flutter mini apps | [View](docs/mini_app_guildes/HOW_TO_ADD_NEW_FLUTTER_MINI_APP.md) | Completed |
| Web Mini App Guide | Instructions for integrating web-based mini apps | [View](docs/mini_app_guildes/HOW_TO_ADD_NEW_WEB_MINI_APP.md) | Completed |
| React Native Mini App Guide | How to add React Native mini apps to the main application | [View](mini_app_guides/HOW_TO_ADD_NEW_REACT_NATIVE_MINI_APP.md) | Review needed |
| iOS Mini App Guide | Instructions for integrating iOS native mini apps | [View](docs/mini_app_guildes/HOW_TO_ADD_NEW_IOS_MINI_APP.md) | Completed |
| Android Mini App Guide | Instructions for integrating Android native mini apps | [View](docs/mini_app_guildes/HOW_TO_ADD_NEW_ANDROID_MINI_APP.md) | Completed |

## [Communication Framework](docs/communication/README.md)

Details on the communication mechanisms between the main app and mini apps.

| File | Description | Link | Status |
|------------------------|-------------|------|--------|
| Communication Guide | Event Bus architecture for communication between main app and mini apps | [View](docs/communication/HOW_MAIN_APP_AND_MINI_APP_COMMUNICATE.md) | Completed |
| Event Bus Architecture | Overview of the Event Bus system, including security and platform-specific implementations | [View](docs/communication/MAIN_APP_COMMUNICATION_ARCHITECTURE.md) | Completed |
| Main App Navigate to Mini App | How to navigate from the main app to a mini app | [View](communication/HOW_MAIN_APP_NAVIGATE_TO_MINI_APP.md)| Review needed |

## [Deployment Strategies](docs/deployment/README.md)

Documentation on deployment methods and configuration management.

### Continuous Integration and Continuous Deployment (CI/CD) strategies.
| File | Description | Link | Status |
|------|-------------|------------------------------------------------------------|--------|
| CI/CD Guide | Overview of CI/CD strategies for mini app development | [View](docs/deployment/ci_cd/HOW_TO_USE_CI_CD.md) | Completed |
| CI/CD for Flutter Mini App | CI/CD strategies specific to Flutter mini apps | [View](docs/deployment/ci_cd/HOW_TO_USE_CI_CD_FLUTTER_MINI_APP.md) | Completed |
| CI/CD for Web Mini App | CI/CD strategies specific to web mini apps | [View](docs/deployment/ci_cd/HOW_TO_USE_CI_CD_WEB_MINI_APP.md) | Completed |
| CI/CD for React Native Mini App | CI/CD strategies specific to React Native mini apps | [View](docs/deployment/ci_cd/HOW_TO_USE_CI_CD_REACT_NATIVE_MINI_APP.md) | Completed |
| CI/CD for iOS Mini App | CI/CD strategies specific to iOS native mini apps | [View](docs/deployment/ci_cd/HOW_TO_USE_CI_CD_IOS_MINI_APP.md) | Completed |
| CI/CD for Android Mini App | CI/CD strategies specific to Android native mini apps | [View](docs/deployment/ci_cd/HOW_TO_USE_CI_CD_ANDROID_MINI_APP.md) | Completed |

### Deployment strategies for different platforms.
| File                     | Description | Link | Status    |
|--------------------------|-------------|------------------------------------------------------------|-----------|
| App Store Deployment     | Guide for deploying applications to the App Store | [View](docs/deployment/store/APP_STORE_DEPLOYMENT.md) | Completed |
| Remote Config Deployment | Using remote config or self-hosted servers for dynamic app configuration | [View](docs/deployment/manage/REMOTE_CONFIG_DEPLOYMENT.md) | Completed |
| Bundle Deployment        | Guide for deploying applications as bundles | [View](docs/deployment/bundle/BUNDLE_DEPLOYMENT.md) | In Progress |
| Code Push Deployment     | Guide for deploying applications using code push | [View](docs/deployment/code_push/CODE_PUSH_DEPLOYMENT.md) | In Progress |


## [Testing and Quality Assurance](docs/testing/README.md)

Documentation on testing strategies and quality assurance practices.

| File | Description | Link | Status |
|------|-------------|------------------------------------------------------------|--------|
| Testing Guide | Overview of testing strategies for mini apps | [View](docs/testing/HOW_TO_TEST_MINI_APP.md) | To Do |
| Unit Testing | Guide for unit testing mini apps | [View](docs/testing/HOW_TO_UNIT_TEST_MINI_APP.md) | To Do |
| Integration Testing | Guide for integration testing mini apps | [View](docs/testing/HOW_TO_INTEGRATION_TEST_MINI_APP.md) | To Do |    
| UI Testing | Guide for UI testing mini apps | [View](docs/testing/HOW_TO_UI_TEST_MINI_APP.md) | To Do |
| Performance Testing | Guide for performance testing mini apps | [View](docs/testing/HOW_TO_PERFORMANCE_TEST_MINI_APP.md) | To Do |
| Security Testing | Guide for security testing mini apps | [View](docs/testing/HOW_TO_SECURITY_TEST_MINI_APP.md) | To Do |
| Load Testing | Guide for load testing mini apps | [View](docs/testing/HOW_TO_LOAD_TEST_MINI_APP.md) | To Do |
| Stress Testing | Guide for stress testing mini apps | [View](docs/testing/HOW_TO_STRESS_TEST_MINI_APP.md) | To Do |
| End-to-End Testing | Guide for end-to-end testing mini apps | [View](docs/testing/HOW_TO_END_TO_END_TEST_MINI_APP.md) | To Do |
| Regression Testing | Guide for regression testing mini apps | [View](docs/testing/HOW_TO_REGRESSION_TEST_MINI_APP.md) | To Do |
| Smoke Testing | Guide for smoke testing mini apps | [View](docs/testing/HOW_TO_SMOKE_TEST_MINI_APP.md) | To Do |
| Acceptance Testing | Guide for acceptance testing mini apps | [View](docs/testing/HOW_TO_ACCEPTANCE_TEST_MINI_APP.md) | To Do |
| Exploratory Testing | Guide for exploratory testing mini apps | [View](docs/testing/HOW_TO_EXPLORATORY_TEST_MINI_APP.md) | To Do |


## How to Use This Documentation

1. Start with the core architecture documents to understand the overall system design
2. Follow the mini app development guides to implement specific types of mini apps
3. Review the communication framework to understand how components interact
4. Refer to deployment strategies when ready to distribute your application
5. Use the links provided to navigate directly to the relevant documentation
6. For any questions or clarifications, refer to the README files in each section for additional context and information
7. If you encounter any issues or need further assistance, please reach out to the project maintainers or community for support

Each document provides detailed instructions, code examples, and best practices specific to its topic.