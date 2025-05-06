# Documentation Summary

This document provides an organized overview of all documentation files in the project, grouped by topic.

## Core Architecture

Documentation covering the fundamental architecture of the main application and mini app ecosystem.

| File | Description | Link                                    |
|------|-------------|-----------------------------------------|
| Main App Architecture | Explains the host platform architecture, benefits of Flutter, and key features | [View](docs/main_app/MAIN_APP.md)       |
| Mini App Architecture | Overview of mini app concepts, supported frameworks, and lifecycle management | [View](docs/mini_app/MINI_APP.md) |

## Mini App Development Guides

Step-by-step guides for creating and integrating mini apps using different technologies.

| File | Description | Link                                                                                 |
|------|-------------|--------------------------------------------------------------------------------------|
| Flutter Mini App Guide | How to create, integrate, and launch Flutter mini apps | [View](docs/mini_app/HOW_TO_ADD_NEW_FLUTTER_MINI_APP.md) |
| Web Mini App Guide | Instructions for integrating web-based mini apps | [View](docs/mini_app/HOW_TO_ADD_NEW_WEB_MINI_APP.md)       |
| React Native Mini App Guide | How to add React Native mini apps to the main application | [View](mini_app/HOW_TO_ADD_NEW_REACT_NATIVE_MINI_APP.md) |

## Communication Framework

Details on the communication mechanisms between the main app and mini apps.

| File                   | Description | Link |
|------------------------|-------------|------|
| Communication Guide    | Event Bus architecture for communication between main app and mini apps | [View](docs/communication/HOW_MAIN_APP_AND_MINI_APP_COMMUNICATE.md) |
| Event Bus Architecture | Overview of the Event Bus system, including security and platform-specific implementations | [View](docs/communication/MAIN_APP_COMMUNICATION_ARCHITECTURE.md) |
| Main App Navigate to Mini App | How to navigate from the main app to a mini app | [View](communication/HOW_MAIN_APP_NAVIGATE_TO_MINI_APP.md)|

## Deployment Strategies

Documentation on deployment methods and configuration management.

| File | Description | Link |
|------|-------------|------|
| App Store Deployment | Guide for deploying applications to the App Store | [View](docs/deploy/APP_STORE_DEPLOYMENT.md) |
| Remote Config Deployment | Using remote config or self-hosted servers for dynamic app configuration | [View](docs/deploy/REMOTE_CONFIG_DEPLOYMENT.md) |
| Bundle Deployment | *Documentation in progress* | [View](docs/deploy/BUNDLE_DEPLOYMENT.md) |
| CodePush Deployment | *Documentation in progress* | [View](docs/deploy/CODEPUSH_DEPLOYMENT.md) |
| Version Management | *Documentation in progress* | [View](docs/deploy/VERSION_MANAGEMENT.md) |

## How to Use This Documentation

1. Start with the core architecture documents to understand the overall system design
2. Follow the mini app development guides to implement specific types of mini apps
3. Review the communication framework to understand how components interact
4. Refer to deployment strategies when ready to distribute your application

Each document provides detailed instructions, code examples, and best practices specific to its topic.