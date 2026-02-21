# AeroSense

**Making sense of the sky.** A modern, responsive Flutter weather dashboard delivering real-time conditions, 5-day forecasts, and air quality metrics.

[![Flutter](https://img.shields.io/badge/Flutter-3.10.8+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.8+-blue.svg)](https://dart.dev)
[![GetX](https://img.shields.io/badge/GetX-4.6.6-purple.svg)](https://getx.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 🌟 Features

- **Real-time Weather Data** powered by Open-Meteo API (free, no API key required)
- **5-Day Forecasts** with detailed hourly and daily predictions
- **Air Quality Metrics** for health-conscious users
- **Location-based Services** with GPS and manual search
- **Beautiful UI** with Material Design 3 and dark mode support
- **Cross-platform** support for Android, iOS, Web, macOS, and Windows

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.10.8 or higher
- Dart 3.10.8 or higher
- Android Studio / Xcode (for mobile development)
- Node.js 18+ (for MCP servers)

### Installation

```bash
# Clone the repository
git clone https://github.com/kmmuntasir/AeroSense.git
cd AeroSense

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Run on Specific Platform

```bash
# Web
flutter run -d chrome

# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Android (requires emulator or device)
flutter run -d android
```

## 🛠️ Development

### Code Quality Checks

Before committing changes, run:

```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Apply automatic fixes
dart fix --apply

# Run tests
flutter test
```

### Build for Production

```bash
# Android (AAB for Play Store)
flutter build appbundle --release

# Android (APK for testing)
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

## 🤖 Claude Code Integration

This project includes **Claude Code skills** and **MCP servers** for AI-assisted development.

### Skills

Project-specific skills are available in `.claude/skills/`:

- **`/pr-review`** - Comprehensive Flutter PR review with GetX patterns, performance checks, and code quality assessment
- **`/mobile-release`** - Complete mobile app release workflow for version bumps, store deployment, and tagging

Usage:
```bash
/pr-review          # Review a pull request or compare branches
/mobile-release     # Create a new production release
```

### MCP Servers

Project-specific MCP servers are configured in `.mcp.json`:

| MCP | Purpose | Required Variables |
|-----|---------|-------------------|
| **Context7** | Up-to-date Flutter/Dart documentation | Optional (see below) |
| **GitHub** | Issues, PRs, releases on remote | `GITHUB_TOKEN` |
| **Figma** | Access Figma designs | `FIGMA_TOKEN` |
| **Trello** | Manage Trello boards | `TRELLO_API_KEY`, `TRELLO_TOKEN` |

#### MCP Setup for Team Members

1. **Copy the environment template:**
   ```bash
   cp .env.example .env.local
   ```

2. **Get your API tokens:**

   | Token | How to Get |
   |-------|------------|
   | `GITHUB_TOKEN` | https://github.com/settings/tokens (scope: `repo`) |
   | `GITHUB_WORK_PAT` | Same as GITHUB_TOKEN (used for GitHub MCP) |
   | `FIGMA_TOKEN` | Figma → Settings → Personal Access Tokens → Create new |
   | `TRELLO_API_KEY` | https://trello.com/app-key |
   | `TRELLO_TOKEN` | Click "Token" link on the app-key page |
   | `CONTEXT7_API_KEY` | https://context7.com/dashboard (optional, free tier) |

3. **Fill in `.env.local`** with your actual tokens

4. **Load environment variables** into your shell (choose one method):

   **Option A: Manual loading (per session)**
   ```bash
   # Load variables in current shell
   export $(grep -v '^#' .env.local | xargs)

   # Then start Claude Code
   claude
   ```

   **Option B: Using direnv (recommended, automatic)**
   ```bash
   # Install direnv
   sudo apt install direnv  # Ubuntu/Debian
   brew install direnv      # macOS

   # Add to shell (~/.bashrc or ~/.zshrc)
   eval "$(direnv hook bash)"  # or zsh

   # Copy the template and allow
   cp .envrc.example .envrc
   direnv allow
   ```

   **Option C: Add to shell profile**
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   source /path/to/AeroSense/.env.local
   ```

5. **Restart Claude Code** to load the MCP servers

**Important:** The `{VARIABLE}` syntax in `.mcp.json` only expands environment variables that are loaded in your shell. Claude Code does **NOT** automatically load `.env.local` files.

**Note:** Context7 works without an API key but with lower rate limits. A free API key provides 60 requests/hour.

### AI Development Rules

The project includes comprehensive development rules in `.agent/rules/`:

- **Flutter Development Rules** - GetX patterns, no hardcoding policy, state management
- **Dart Style Guide** - Naming conventions, formatting, code organization
- **Flutter Testing Rules** - Unit, widget, and integration testing best practices
- **Git Guidelines** - Branch naming, commit messages (PROJECT_SLUG: **AERO**)
- **Single Task Workflow** - 7-step implementation process

See [CLAUDE.md](CLAUDE.md) for complete AI assistant guidelines.

## 📁 Project Structure

```
lib/
├── core/              # Shared utilities, services, themes
│   ├── controllers/   # Global controllers (Location, Weather, Settings)
│   ├── services/      # API clients and providers
│   ├── models/        # Data models and DTOs
│   └── themes/        # Light/Dark theme definitions
├── data/              # Data layer (datasources, repositories)
├── domain/            # Business logic layer (entities, use cases)
├── presentation/      # UI layer (pages, widgets, bindings)
└── routes/            # App routing configuration
```

## 🔧 Architecture

**State Management:** GetX (controllers, bindings, reactive variables)

**Key Patterns:**
- One controller per page with `Get.lazyPut()` in bindings
- `StatelessWidget` with `Obx()` for reactive UI
- No hardcoded values (use theme tokens and constants)
- Proper separation: Controllers (logic) → Widgets (UI)

**Data Sources:**
- **Weather API:** Open-Meteo (https://api.open-meteo.com/v1/forecast)
- **Geocoding API:** Open-Meteo (https://geocoding-api.open-meteo.com/v1/search)
- **Local Storage:** GetStorage for favorites and settings

## 🎨 Theming

**Light Mode:** Background `#F8F9FA`, Primary `#4A90E2`

**Dark Mode:** Background `#121212` or `#1E2124`

All colors and styles use theme tokens - no hardcoded values in widgets.

## 📱 Platform Configuration

### Android

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS

Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show weather for your area.</string>
```

## 🔐 Environment Variables

Copy `.env.example` to `.env.local` and configure:

```bash
cp .env.example .env.local
# Edit .env.local with your tokens
```

**Important:** `.env.local` is gitignored and should never be committed.

## 📚 Documentation

- **[CLAUDE.md](CLAUDE.md)** - AI assistant guidelines and development rules
- **[.agent/rules/](.agent/rules/)** - Development standards and workflows
- **[docs/](docs/)** - Project documentation (API docs, PRD, technical specs)

## 🔗 Project Links

- **Trello Board:** https://trello.com/b/z8XwZF3U/aerosense-kanban
- **Figma Design:** https://www.figma.com/design/nbEaJycmx0bstnYhVfTJ86/AeroSense
- **GitHub Repository:** https://github.com/kmmuntasir/AeroSense

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/weather_controller_test.dart

# Integration tests
flutter test integration_test/
```

**Coverage Targets:**
- Business Logic: >80%
- Models: 100%
- Widgets: >70%
- Integration: All critical flows

## 📦 Dependencies

See [pubspec.yaml](pubspec.yaml) for complete list.

Key dependencies:
- `get: ^4.6.6` - State management, routing, DI
- `dio: ^5.4.0` - HTTP client
- `geolocator: ^14.0.2` - Location services
- `permission_handler: ^12.0.1` - Runtime permissions
- `get_storage: ^2.1.1` - Local storage

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/AERO-123-description`
2. Follow the [Single Task Workflow](.agent/rules/single-task-workflow.md)
3. Commit with format: `AERO-123: Add feature description`
4. Push and create a pull request
5. Use `/pr-review` skill for self-review

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Muntasir** - Project Lead

## 🙏 Acknowledgments

- **Open-Meteo** for free weather and geocoding APIs
- **Flutter Team** for the amazing framework
- **GetX Community** for the state management solution

---

**Project Slug:** AERO | **Version:** 1.0.0 | **Status:** In Development
