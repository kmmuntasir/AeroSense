---
description: How to create a new release for AeroSense Flutter app
---

# Mobile Release Process Workflow

Follow these steps to create a new official release of the AeroSense Flutter mobile application. Remember that these version numbers are examples, use the actual version numbers.

### 1. Version Detection & Branch Check

- Verify if the current branch follows the `release/x.y.z` pattern.
- If not, check the latest git tag (e.g., `v1.0.0`), suggest the next version (`v1.0.1`), and ask the user to confirm creating a new release branch: `git checkout -b release/1.0.1`.
- Confirm the version format: `version: x.y.z+z` where:
  - `x.y.z` is the semantic version (major.minor.patch)
  - `+z` is the build number (incrementing integer)

Example: `version: 1.0.1+2`

### 2. Version Synchronization

- Update the version in `pubspec.yaml`:
  ```yaml
  version: 1.0.1+2  # Update both version and build number
  ```
- Update the version in root `project-metadata.md` file if it exists.
- If there's a `VERSION` file, update it as well (no `v` prefix).

### 3. Dependency Management

- Sync dependencies: `flutter pub get`
- Check for outdated packages: `flutter pub outdated`
- Update any packages that have major version updates if needed: `flutter pub upgrade`

### 4. Code Quality & Linting

- Run code analysis: `flutter analyze`
- Fix any issues found (use `dart fix --apply` for automatic fixes)
- Format code: `dart format .`

### 5. Build & Verification

- **Analyze code**: `flutter analyze`
- **Run tests**: `flutter test`
- **Run integration tests** (if available): `flutter test integration_test/`
- **Build Android APK** (for testing):
  ```bash
  flutter build apk --release
  ```
- **Build Android App Bundle** (for Play Store):
  ```bash
  flutter build appbundle --release
  ```
- **Build iOS** (for App Store Connect):
  ```bash
  flutter build ios --release
  ```
- Test the generated APK/AAB on a physical device or emulator

### 6. Feature & Change Analysis

- Compare the current branch with the latest release tag: `git log v1.0.0..HEAD`
- Analyze commit messages and code changes since the last tag.
- Identify breaking changes, new features, bug fixes, and improvements.

### 7. Release Note Generation

- Create a new comprehensive release note in `docs/release-notes/` (if directory exists) using the established format:
  - Header, Overview, Major Features, Enhancements, Technical Improvements, Bug Fixes, Known Issues, Dependencies, Notes.
  - Header Example:
  ```markdown
  # AeroSense Release Note - v1.0.1

  **Release Date:** November 17, 2025
  **Previous Release:** v1.0.0 (November 06, 2025)
  **Branch Comparison:** `v1.0.0` with `release/1.0.1`
  **Platform:** Flutter (iOS/Android)
  ```

### 8. Changelog Update

- Create or update `CHANGELOG.md` at the root if it doesn't exist:
  ```markdown
  # Changelog

  All notable changes to the AeroSense app will be documented in this file.

  The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

  ## [1.0.1] - 2025-11-17

  ### Added
  - Location search functionality
  - Weather data caching for offline access

  ### Changed
  - Improved onboarding flow with better permission handling
  - Updated to GetX 4.6.6

  ### Fixed
  - Fixed crash when location permission is denied
  - Fixed temperature unit conversion bug

  ### Removed
  - N/A

  ## [1.0.0] - 2025-11-06

  ### Added
  - Initial release of AeroSense
  - Real-time weather data display
  - 5-day weather forecast
  ```
  - For detailed changes, refer to release notes in `docs/release-notes/`

### 9. Commit & Push

- Run:
  ```bash
  git add pubspec.yaml project-metadata.md CHANGELOG.md docs/release-notes/
  git commit -m "AERO-XXXX: Release v1.0.1"
  git push origin release/1.0.1
  ```

### 10. Tagging & GitHub Release

- Create and push tag:
  ```bash
  git tag -a v1.0.1 -m "AeroSense Release v1.0.1"
  git push origin v1.0.1
  ```
- Create GitHub Release using `gh` CLI:
  ```bash
  gh release create v1.0.1 --title "AeroSense v1.0.1" --notes-file docs/release-notes/YYYY-MM-DD-RELEASE_NOTE_v1.0.1.md
  ```
  Or manually create the release on GitHub with the release notes.

### 11. Store Deployment

#### Android - Google Play Store

1. **Upload to Google Play Console**:
   - Go to [Google Play Console](https://play.google.com/console)
   - Navigate to the app
   - Create a new release (Internal Testing → Closed Testing → Open Testing → Production)
   - Upload the AAB file: `build/app/outputs/bundle/release/app-release.aab`
   - Fill in release notes
   - Submit for review

2. **Version Codes**:
   - Android `versionCode` is auto-generated from `pubspec.yaml` version (`+z` part)
   - Ensure it's higher than the previous release

#### iOS - App Store Connect

1. **Upload to App Store Connect**:
   - Use Xcode or Transporter to upload the IPA
   - Or use command line:
     ```bash
     # Build and upload (requires Xcode and valid Apple Developer account)
     flutter build ios --release
     # Then open Xcode and use Product > Archive or use Transporter
     ```

2. **Create App Store Release**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Navigate to the app
   - Create a new version
   - Fill in release notes and metadata
   - Submit for review

### 12. Post-Release Verification

After deployment:

- **Internal Testing**:
  - Test on physical devices (iOS and Android)
  - Verify all critical user flows work
  - Check for crashes or issues

- **Monitor**:
  - Check Firebase Crashlytics for crashes
  - Monitor app performance
  - Review user feedback and ratings

- **Merge Release Branch**:
  ```bash
  git checkout main
  git merge release/1.0.1
  git push origin main
  ```

### 13. Cleanup (Optional)

- Delete the release branch after merging:
  ```bash
  git branch -d release/1.0.1
  git push origin --delete release/1.0.1
  ```

## Quick Reference Commands

```bash
# Version check
flutter --version

# Update dependencies
flutter pub get
flutter pub upgrade

# Run tests
flutter test
flutter test integration_test/

# Analyze code
flutter analyze
dart format .

# Build for Android
flutter build apk --release
flutter build appbundle --release

# Build for iOS
flutter build ios --release

# Create tag
git tag -a v1.0.1 -m "Release v1.0.1"
git push origin v1.0.1

# Create GitHub release
gh release create v1.0.1 --title "v1.0.1" --notes "Release notes here"
```

## Release Notes Template

```markdown
# AeroSense Release Note - v{VERSION}

**Release Date:** {DATE}
**Previous Release:** v{PREV_VERSION} ({PREV_DATE})
**Branch Comparison:** `v{PREV_VERSION}` with `release/{VERSION}`
**Platform:** Flutter (iOS/Android)

## Overview
{BRIEF_DESCRIPTION_OF_RELEASE}

## Major Features
- {FEATURE_1}
- {FEATURE_2}

## Enhancements
- {IMPROVEMENT_1}
- {IMPROVEMENT_2}

## Bug Fixes
- {FIX_1}
- {FIX_2}

## Technical Improvements
- {TECHNICAL_CHANGE_1}
- {TECHNICAL_CHANGE_2}

## Dependencies
| Package | Old Version | New Version |
|---------|-------------|-------------|
| flutter | x.x.x | x.x.x |
| get | x.x.x | x.x.x |

## Known Issues
- {KNOWN_ISSUE_1}

## Notes
- {ADDITIONAL_NOTES}
```
