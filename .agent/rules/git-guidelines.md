---
trigger: model_decision
description: Ruleset that MUST be followed when executing ANY git command
---

# Git Guidelines

## Sacred Rule:
- NEVER run a `git` command without user's explicit approval.

## Project Slug:
- PROJECTSLUG is a shortened name for the project to be used as an abbreviation for several things, example: JIRA tickets.
- PROJECTSLUG for this project is: **AERO**
- Can be found in the `./project-metadata.md` file.

## Branch Naming:
- Format: type/PROJECTSLUG-TICKET_NUMBER-hyphenated-short-description
- Example: `feature/AERO-123-add-location-search`, `bugfix/AERO-234-fix-permission-crash`
- Exception: Release branches should be named like this: `release/1.2.3`, no description or ticket number, just the version number.
- Use imperative, hyphenated style for description.
- Never assume ticket number. If missing, omit it.
- Note: If the project uses Trello, then Card Number should be used in place of Ticket number.

## Commit Messages:
- ALWAYS use single line commit message
- Format: PROJECTSLUG-TICKET_NUMBER: message
- Example: `AERO-123: Add location permission handling`
- Extract ticket number from branch name
- If ticket is not identifiable, omit prefix and write message only.

## Flutter-Specific Git Ignore Patterns

The following should be excluded from version control (already in `.gitignore`):

### Build Outputs
- `build/` - Flutter build outputs (APK, IPA, etc.)
- `.dart_tool/` - Dart build tools cache
- `android/.gradle/` - Android Gradle cache
- `android/app/build/` - Android app build outputs
- `android/local.properties` - Local Android SDK path
- `ios/Pods/` - iOS CocoaPods dependencies
- `ios/.symlinks/` - iOS symlinks
- `ios/Flutter/Flutter.framework` - iOS Flutter framework
- `ios/Flutter/Flutter.podspec` - iOS Flutter podspec
- `*.ipa` - iOS app bundle
- `*.apk` - Android app package
- `*.aab` - Android app bundle

### IDE & Editor Files
- `.idea/` - IntelliJ/Android Studio
- `.vscode/` - VS Code (optional, can be included)
- `*.iml` - IntelliJ module files
- `.metadata` - Eclipse metadata
- `.settings/` - Eclipse settings

### OS Files
- `.DS_Store` - macOS Finder
- `Thumbs.db` - Windows thumbnails

### Sensitive Files
- `android/key.properties` - Android signing keys (NEVER commit)
- `*.keystore` - Android keystore files (NEVER commit)
- `*.jks` - Java KeyStore files (NEVER commit)
- `ios/*.mobileprovision` - iOS provisioning profiles
- `ios/*.p12` - iOS signing certificates

### Firebase & Configuration
- `google-services.json` - Firebase config for Android
- `GoogleService-Info.plist` - Firebase config for iOS
- `lib/firebase_options.dart` - Generated Firebase options

### Environment Files
- `.env` - Environment variables
- `.env.*` - Environment variant files
- `! .env.example` - Keep example files

### Debug & Test Files
- `test_driver/` - Integration test driver files (if sensitive)
- `flutter_app.log` - Flutter debug logs

## Example .gitignore Entries

If any of the above are missing from `.gitignore`, add them. Never commit sensitive build artifacts.

## Release Workflow

For release branches and tagging, follow the mobile release workflow in `.agent/workflows/mobile-release.md`.
