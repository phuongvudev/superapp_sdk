# Version Management Guide

This document outlines the best practices and strategies for managing versions in both the main app and mini apps.
It serves as a comprehensive guide to ensure consistent versioning, compatibility, and release management across the entire application ecosystem.
It is intended for developers, project managers, and anyone involved in the deployment and maintenance of the application.
It includes guidelines for versioning, release notes, backward compatibility, and tools to automate the process.

---

## Versioning Strategy

### Semantic Versioning
Use **Semantic Versioning (SemVer)** for all components (main app and mini apps):
- **MAJOR**: Incompatible API changes.
- **MINOR**: Backward-compatible new features.
- **PATCH**: Backward-compatible bug fixes.

Format: `MAJOR.MINOR.PATCH` (e.g., `1.2.3`).

---

## Main App Version Management

1. **Versioning in `pubspec.yaml`**:
   - Define the app version in `pubspec.yaml`:
     ```yaml
     version: 1.2.0+3 # Format: versionName+versionCode
     ```
   - The version follows the format `MAJOR.MINOR.PATCH+BUILD_NUMBER` where:
      - `1.2.0` is the public version name (following SemVer)
      - `3` is the build number (increment for every release)

2. **Backward Compatibility**:
    - Ensure the main app supports older versions of mini apps.
    - Use feature flags to handle new features without breaking older mini apps.

3. **Release Notes**:
    - Document changes for every release (e.g., new features, bug fixes, breaking changes).

4. **Version Tracking**:
    - Use tools like Git tags to track releases:
      ```bash
      git tag -a v1.2.0 -m "Main app version 1.2.0"
      git push origin v1.2.0
      ```

---

## Mini App Version Management

1. **Independent Versioning**:
    - Each mini app should have its own versioning independent of the main app.

2. **Version Compatibility**:
    - Maintain a compatibility matrix to ensure mini apps work with specific main app versions.

3. **Version Declaration**:
    - For Flutter mini apps, define the version in `pubspec.yaml`:
      ```yaml
      version: 1.0.0
      ```

    - For native mini apps, use `build.gradle` (Android) or `Info.plist` (iOS).
    - For web mini apps, use `package.json`:
      ```json
      {
        "version": "1.0.0"
      }
      ```
    - For React Native mini apps, use `package.json`:
      ```json
      {
        "version": "1.0.0"
      }
      ```

4. **Backward Compatibility**:
    - Use the event bus or bridges to ensure communication between mini apps and the main app remains stable across versions.

5. **Lazy Loading**:
    - Load mini apps dynamically based on their version to reduce dependency on the main app.

---

## Shared Guidelines

1. **Version Synchronization**:
    - Use a shared versioning policy for APIs and communication protocols between the main app and mini apps.

2. **Changelog Maintenance**:
    - Maintain a changelog for both the main app and mini apps to document changes.

3. **Testing**:
    - Test mini apps with multiple versions of the main app to ensure compatibility.
    - Automate version compatibility tests using CI/CD pipelines.

4. **Dependency Management**:
    - Use dependency management tools (e.g., Gradle, Pub) to ensure proper version resolution.

5. **Release Process**:
    - Tag releases in Git for both the main app and mini apps.
    - Use versioning tools like `git-flow` for structured release management.

---

## Tools for Version Management

Here are some tools you can use to automate version management:

1. **Git Tags**: For tagging and tracking releases in Git.
2. **Gradle Version Catalog**: Manages dependencies and versions in Gradle projects.
3. **Pub**: Handles versioning for Flutter projects.
4. **Semantic Release**: Automates versioning and changelog generation based on commit messages.
5. **CI/CD Pipelines**: Automates version checks, builds, and compatibility testing.
6. **npm Version**: Automates versioning for JavaScript projects using `npm version`.
7. **GitHub Actions**: Automates workflows, including versioning and release processes.
8. **Fastlane**: Automates version bumping and release tasks for mobile apps.
9. **VersionEye**: Monitors dependencies and ensures proper versioning.
10. **Release Drafter**: Automatically drafts release notes based on merged pull requests.

---

## Best Practices

1. **Increment Versions Consistently**:
    - Always increment the version for every release, even for minor changes.
2. **Document Breaking Changes**:
    - Clearly communicate breaking changes in release notes.
3. **Use Feature Flags**:
    - Gradually roll out new features to avoid compatibility issues.
4. **Monitor Compatibility**:
    - Regularly test mini apps with the latest main app version.
5. **Version Locking**:
    - Lock dependencies to specific versions to avoid unexpected issues.

This guide ensures a structured approach to version management for both the main app and mini apps.