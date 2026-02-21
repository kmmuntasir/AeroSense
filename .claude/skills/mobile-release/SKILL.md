---
name: mobile-release
description: Complete Flutter mobile app release workflow for AeroSense. Covers version bump, quality checks, building APK/AAB, store deployment to Google Play and App Store, tagging, and post-release tasks. Use when creating a new production release.
---

# Mobile Release Skill

Complete workflow for creating an official AeroSense release. Use when user requests to create a release, deploy to stores, or prepare a new version.

## Prerequisites

- User is on a release branch or main branch
- All features for the release are merged
- User has permission to push to remote and create releases

## 1. Version Detection & Branch Check

```bash
# Check current branch
git branch --show-current

# If not on release branch, create one
git checkout -b release/x.y.z
```

**Version format:** `x.y.z+z` where `x.y.z` is semantic version and `+z` is build number.
- Example: `version: 1.0.1+2`
- Project slug: **AERO**
- Ticket format: `AERO-XXXX`

## 2. Update Version Files

Update the following files with the new version:

- **`pubspec.yaml`**: `version: x.y.z+z`
- **`project-metadata.md`**: Update version
- **`VERSION`** (if exists): `x.y.z` (no `v` prefix)

## 3. Dependencies & Quality Checks

Always run before building:

```bash
# Install dependencies
flutter pub get

# Check for outdated packages
flutter pub outdated

# Analyze code for issues
flutter analyze

# Format code
dart format .

# Apply automatic fixes
dart fix --apply

# Run all tests
flutter test
```

If any tests fail or issues are found, fix them before proceeding.

## 4. Build & Test

### Android
```bash
# For testing
flutter build apk --release

# For Play Store (recommended)
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
# Then use Xcode to upload
```

**Test the build** on a physical device or emulator before proceeding.

## 5. Analyze Changes

```bash
git log vPREVIOUS_VERSION..HEAD --oneline
```

Identify:
- Breaking changes
- New features
- Bug fixes
- Improvements

## 6. Create Release Notes

Create `docs/release-notes/YYYY-MM-DD-RELEASE_NOTE_vX.Y.Z.md`:

```markdown
# AeroSense Release Note - vX.Y.Z

**Release Date:** {DATE}
**Previous Release:** vX.Y.Z ({DATE})
**Branch Comparison:** `vX.Y.Z` with `release/X.Y.Z`

## Added
- New feature 1
- New feature 2

## Changed
- Improvement 1
- Updated package X to v2.0

## Fixed
- Bug fix 1
- Bug fix 2

## Known Issues
- Issue 1 (if any)
```

## 7. Update Changelog

Add to `CHANGELOG.md` (create if doesn't exist):

```markdown
## [X.Y.Z] - YYYY-MM-DD
### Added
- Location search
### Changed
- Improved onboarding
### Fixed
- Permission crash
```

## 8. Commit & Push

```bash
git add pubspec.yaml project-metadata.md CHANGELOG.md docs/release-notes/
git commit -m "AERO-XXXX: Release vX.Y.Z"
git push origin release/X.Y.Z
```

**Sacred Rule:** Always get user confirmation before running git commands.

## 9. Tag & GitHub Release

```bash
# Create annotated tag
git tag -a vX.Y.Z -m "Release vX.Y.Z"

# Push tag to remote
git push origin vX.Y.Z

# Create GitHub release
gh release create vX.Y.Z --title "vX.Y.Z" --notes-file docs/release-notes/YYYY-MM-DD-RELEASE_NOTE_vX.Y.Z.md
```

## 10. Store Deployment

### Android (Google Play Store)

1. Go to [Play Console](https://play.google.com/console)
2. Create release track: Internal → Closed → Open → Production
3. Upload: `build/app/outputs/bundle/release/app-release.aab`
4. Add release notes
5. Submit for review

### iOS (App Store Connect)

1. Build: `flutter build ios --release`
2. Open Xcode: `open ios/Runner.xcworkspace`
3. Product → Archive → Distribute App
4. Or use Transporter app
5. Go to [App Store Connect](https://appstoreconnect.apple.com)
6. Create new version, upload build
7. Submit for review

## 11. Post-Release

```bash
# Merge to main
git checkout main
git merge release/X.Y.Z
git push origin main

# Optional: Delete release branch
git branch -d release/X.Y.Z
git push origin --delete release/X.Y.Z
```

## Quick Commands Reference

```bash
# Prep
flutter pub get && flutter analyze && dart format . && flutter test

# Build
flutter build appbundle --release
flutter build ios --release

# Git
git tag -a vX.Y.Z -m "Release" && git push origin vX.Y.Z
gh release create vX.Y.Z --title "vX.Y.Z" --notes "Release notes"
```

---

## Notes

- **Project Slug:** AERO
- **Trello Board:** https://trello.com/b/z8XwZF3U/aerosense-kanban
- **GitHub:** https://github.com/kmmuntasir/AeroSense

Always verify on physical devices, monitor for crashes, and review user feedback post-release.
