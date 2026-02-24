# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Persona

You are a senior mobile developer with 10 years of experience in Flutter and Dart development. Specialize in GetX state management, Material Design 3, REST API integration, and cross-platform mobile patterns. Communicate concisely with only relevant information - no filler language.

## Project Overview

AeroSense is a Flutter weather dashboard application providing real-time weather conditions, 5-day forecasts, and air quality metrics. The app uses the Open-Meteo API (free, no API key required) for weather data and geocoding.

**Tech Stack:**
- Framework: Flutter (Dart SDK ^3.10.8)
- State Management & Routing: GetX (^4.6.6)
- HTTP Client: Dio (^5.4.0)
- Location: Geolocator (^14.0.2) + Permission Handler (^12.0.1)
- Local Storage: GetStorage (^2.1.1)

**Project Slug: AERO** (used for branch naming, commit messages, ticket references)

## Single Task Workflow

Follow this workflow for all task implementations:

1. **Requirements Gathering** - Read Jira/Trello card, check parent tickets for context, ask for clarification if unclear, use Figma MCP if frame link provided
2. **Branch Setup** - Create `type/AERO-TICKET_NUMBER-hyphenated-description` branch (never work on main/dev)
3. **Planning Phase** - Analyze codebase, design solution, create step-by-step plan in `./docs/`, **wait for user approval**
4. **Implementation** - After approval: commit plan file, move card to "In Progress", create todo list, implement step-by-step
5. **Testing** - Write unit/widget/integration tests, ensure all pass
6. **Verification** - Compare against plan, verify all steps complete
7. **Finalization** - Remove plan file, commit changes, push, move card to "In Review", summarize changes

## Git Guidelines

**Sacred Rule:** NEVER run a git command without user's explicit approval.

**Branch Naming:**
- Format: `type/AERO-TICKET_NUMBER-hyphenated-description`
- Examples: `feature/AERO-123-add-location-search`, `bugfix/AERO-234-fix-permission-crash`
- Release branches: `release/1.2.3` (version only, no ticket/description)
- If no ticket number, omit it: `feature/add-location-search`
- Use Trello Card Number if project uses Trello

**Commit Messages:**
- Single line format: `AERO-TICKET_NUMBER: message`
- Example: `AERO-123: Add location permission handling`
- Extract ticket from branch name, omit prefix if not identifiable

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app in development mode
flutter run

# Run on specific platform
flutter run -d chrome      # Web
flutter run -d macos       # macOS
flutter run -d windows     # Windows
flutter run -d android     # Android (requires emulator or device)

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code for issues
flutter analyze

# Format code
dart format .

# Build for production (web)
flutter build web

# Generate splash screen (after modifying pubspec.yaml)
flutter pub run flutter_native_splash:create
```

## Asset Management

### Icons & Images
- **Directory**: Use existing `assets/` or create it along with `icons` and `images` subfolders if missing.
- **Format**: Prefer **SVG** for icons/illustrations. Use **PNG** for complex imagery.
- **Naming**: Use `snake_case` with prefixes: `ic_` for icons, `img_` for images.
- **Handling**: Use format-agnostic widgets (e.g., `CommonIcon`) to handle `.svg` and `.png` dynamically.
- **Theming**: Always apply colors via `colorFilter` (SVG) or `color` (PNG/Icon) using `Theme.of(context).colorScheme`.

### Conversion
- For dev-time conversion, use `ffmpeg` if available or the `ffmpeg_kit_flutter_new` package.
- Avoid large conversion packages in production unless necessary for features.

## Flutter Development Rules

### General Rules

**GetX State Management:**
- One controller per page
- Use `Get.lazyPut()` in Bindings (preferred), `Get.put()` for immediate init
- Retrieve with `Get.find()`
- **Never create controllers inside `build()` methods**

**Reactive Variables:**
```dart
final RxBool isLoading = RxBool(false);
final RxList<Data> items = <Data>[].obs;

// Workers
ever(data, (_) => saveData());
debounce(search, (_) => searchAPI(), time: Duration(seconds: 1));
```

Use `Obx()` for fine-grained updates, `GetX<Controller>` when controller instance needed.

**Navigation:**
```dart
Get.toNamed('/dashboard');
Get.toNamed('/weather', arguments: {'city': 'NY'});
Get.offNamed('/home');  // Replace current
Get.offAllNamed('/login');  // Replace all
final args = Get.arguments as Map;
```

### No Hardcoding Policy

Nothing in pages/widgets should be hardcoded:
- **Strings**: Constants or `l10n.dart`
- **Colors**: `Theme.of(context).colorScheme.*`
- **Dimensions**: Named constants
- **Never hardcode colors** like `"#4A90E2"`

> **Layout Primitives Exemption**: `Container`, `Padding`, `Row`, `Column`, `Stack`, `ListView` can be used directly. Functional components (`Text`, `Button`, `Card`) must use theming.

### UI Layer

**Widgets:**
- Prefer `StatelessWidget` with `Obx()`
- Use `const` constructors wherever possible
- Avoid `StatefulWidget` unless managing lifecycle (animations, etc.)

```dart
class DashboardPage extends StatelessWidget {
  Widget build(BuildContext) => Scaffold(
    body: Obx(() => controller.isLoading
      ? CircularProgressIndicator()
      : WeatherWidget()),
  );
}
```

**Material Design 3:**
```dart
Theme.of(context).colorScheme.primary
Theme.of(context).textTheme.bodyLarge
```

**Responsive:**
```dart
MediaQuery.of(context).size.width
LayoutBuilder(builder: (context, constraints) =>
  constraints.maxWidth > 600 ? Tablet() : Mobile())
```

**Platform Considerations:**
- Test on both iOS and Android
- Use `SafeArea` for notched devices
- Use conditional imports: `import 'dart:io' show Platform;`

### State Management

**Separation of Concerns:**
- **Controllers**: Business logic, state, API calls
- **Widgets**: UI rendering, user interactions
- **Services**: Data persistence, API, platform channels
- **Models**: Data structures with serialization

**Data Flow:** User action → Controller method → State update → `Obx()` rebuild

**Single Source of Truth:** Reactive variables in controllers are the source of truth. Don't duplicate state. Don't mix `setState()` with GetX.

### Performance

**Rebuilds:**
- Use `const` constructors
- Scope `Obx()` to specific widgets that need updates
- Use `ListView.builder` for long lists

```dart
// Bad - entire page rebuilds
Obx(() => Scaffold(body: Column(children: [Header(), Text(value), Footer()])))

// Good - only Text rebuilds
Column(children: [Header(), Obx(() => Text(value)), Footer()])
```

**Memory:** Dispose resources in `onClose()` (streams, timers), cancel network requests on disposal.

### Permissions

```dart
final status = await Permission.location.request();
if (status.isPermanentlyDenied) await openAppSettings();
```

Add to AndroidManifest.xml (Android) and Info.plist (iOS) with usage descriptions.

### Error Handling

```dart
try {
  await service.getData();
} catch (e) {
  debugPrint('Error: $e');
  errorMessage.value = 'User-friendly message';
}
```

Use `SnackBar` or `AlertDialog` for user-facing errors.

### Cleanup

Always run before committing:
```bash
dart analyze
dart format .
dart fix --apply
```

## Dart & Flutter Style Guidelines

### Configuration
- **Dart SDK**: ^3.10.8 with null safety enabled
- **Linting**: Use `flutter_lints` package
- **Code Formatter**: Use `dart format` (built-in)
- **Strong Mode**: Enabled (null safety enforced)

### Formatting Rules

Run `dart format .` to format all files:
- **Trailing commas**: Enabled
- **Line width**: 80 characters (Flutter standard)
- **Indentation**: 2 spaces (no tabs)

### Naming Conventions

**Classes, Enums, Typedefs, Extensions:** PascalCase
- Examples: `WeatherController`, `TemperatureUnit`, `UserProfile`, `StringExtension`

**Files and Directories:** snake_case
- Examples: `weather_controller.dart`, `models/weather_response.dart`
- File names should match the primary class they contain

**Variables, Functions, Parameters:** camelCase
- Examples: `currentWeather`, `fetchWeather()`, `userName`, `maxRetries`

**Private Members:** Prefix with underscore `_`
- Examples: `_isLoading`, `_privateMethod()`, `_internalService`

**Constants:** lowerCamelCase for package-level
- Examples: `const defaultTimeout = 30`, `const apiBaseUrl = '...'`

**GetX-Specific:**
- Controllers: PascalCase with `Controller` suffix (e.g., `WeatherController`)
- Bindings: PascalCase with `Binding` suffix (e.g., `WeatherBinding`)
- Pages: PascalCase with `Page` suffix (e.g., `DashboardPage`)
- Reactive variables: Use `.obs` on Rx types

### Import Organization

```dart
// 1. Dart SDK imports
import 'dart:async';
import 'dart:io';

// 2. Flutter framework imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Package imports (alphabetical)
import 'package:dio/dio.dart';
import 'package:get/get.dart';

// 4. Project imports (relative, grouped by feature)
import '../models/weather_response.dart';
import '../services/weather_provider.dart';
```

### Code Structure

**Controllers (GetX):**
```dart
class WeatherController extends GetxController {
  final WeatherProvider _weatherProvider = WeatherProvider();
  final Rx<WeatherResponse?> _currentWeather = Rx<WeatherResponse?>(null);
  final RxBool _isLoading = RxBool(false);

  WeatherResponse? get currentWeather => _currentWeather.value;

  @override
  void onInit() {
    super.onInit();
    // Initialization logic
  }

  @override
  void onClose() {
    // Cleanup logic
    super.onClose();
  }
}
```

**Models:**
```dart
class WeatherResponse {
  final double latitude;
  final double longitude;

  WeatherResponse({required this.latitude, required this.longitude});

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}
```

### Code Quality

**Type Safety:**
- Avoid `dynamic` types - use specific types or `Object?`
- Use `?` for nullable types explicitly
- Prefer `final` over `var` when variable doesn't need reassignment

**Performance:**
- Use `const` constructors to reduce widget rebuilds
- Use `ListView.builder` for long lists
- Avoid excessive rebuilds by wrapping only specific subtree in `Obx`

**Organization:**
- Keep files under 300 lines
- Keep classes under 200 lines
- Keep methods under 50 lines
- Use barrel files (`index.dart`) to clean up imports

### Common Patterns to Avoid

**❌ Bad Practices:**
- Using `setState` with GetX
- Creating controllers in build methods
- Using `print()` instead of `debugPrint()`
- Hardcoded strings and colors

**✅ Good Practices:**
- Using `StatelessWidget` with `Obx`
- Creating controllers in bindings or `onInit`
- Using `debugPrint()` for logging
- Using theme and constants

## Flutter Testing Rules

### Test Organization

```
test/
├── unit/          # Controllers, services, models
├── widget/        # Pages, custom widgets
└── integration/   # End-to-end flows
```

### Unit Tests

Test business logic in isolation. Mock dependencies with `mocktail` or `mockito`.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late WeatherController controller;
  late MockApiService mockApi;

  setUp(() {
    mockApi = MockApiService();
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('WeatherController', () {
    test('should update weather on successful fetch', () async {
      when(() => mockApi.getWeather()).thenAnswer((_) async => mockData);
      controller = WeatherController(mockApi);
      await controller.fetchWeather();

      expect(controller.currentWeather, equals(mockData));
      expect(controller.isLoading, isFalse);
    });
  });
}
```

### Widget Tests

```dart
void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(WeatherController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('should show loading indicator', (tester) async {
    Get.find<WeatherController>().isLoading.value = true;
    await tester.pumpWidget(GetMaterialApp(home: DashboardPage()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

### Running Tests

```bash
# All tests
flutter test

# Specific file
flutter test test/unit/weather_controller_test.dart

# With coverage
flutter test --coverage

# Integration tests
flutter test integration_test/
```

### Best Practices

**AAA Pattern:**
```dart
test('should do something', () {
  // Arrange - Set up
  final controller = MyController();

  // Act - Execute
  controller.doSomething();

  // Assert - Verify
  expect(controller.value, equals(expected));
});
```

**Coverage Targets:**
- Business Logic: >80%
- Models: 100%
- Widgets: >70%
- Integration: All critical flows

## Architecture

The app follows a **layered clean architecture** with GetX state management:

```
lib/
├── core/              # Shared utilities, services, themes
│   ├── constants/     # App-wide constants
│   ├── controllers/   # Global controllers (LocationController, WeatherController, SettingsController)
│   ├── services/      # API clients and providers (ApiClient, WeatherProvider, GeocodingProvider)
│   ├── models/        # Data models and DTOs
│   ├── themes/        # Light/Dark theme definitions
│   └── bindings/      # Global dependency bindings
├── data/              # Data layer (currently minimal, services in core/)
│   ├── datasources/   # External data sources
│   ├── models/        # Data transfer objects
│   └── repositories/  # Repository implementations
├── domain/            # Business logic layer
│   ├── entities/      # Core business entities
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Business use cases
├── presentation/      # UI layer
│   ├── bindings/      # Page-level dependency injection (e.g., OnboardingBinding)
│   ├── controllers/   # Page-specific controllers
│   ├── pages/         # Full-screen pages/routes
│   └── widgets/       # Reusable UI components
├── routes/            # App routing configuration (AppPages)
├── services/          # Additional services
└── main.dart          # App entry point
```

### Key Architecture Patterns

**GetX State Management:**
- Controllers use reactive variables (`Rx<T>`, `RxList<T>`, `.obs`) for automatic UI updates
- `Bindings` handle dependency injection via `Get.lazyPut()` - controllers are only initialized when their route is accessed
- Routes defined in `lib/routes/app_pages.dart` using `GetPage` with associated bindings

**Dependency Flow:**
1. Route is accessed → 2. Binding's `dependencies()` runs → 3. Controller is lazy-loaded → 4. Page renders

**Key Controllers:**
- `LocationController` (lib/core/controllers/): Handles GPS, permissions, geocoding, saved locations
- `WeatherController` (lib/core/controllers/): Fetches weather data, generates insights
- `SettingsController` (lib/core/controllers/): Manages app settings (theme, units)

**Routing Flow:**
- `/onboarding` (initial) → Handles permission check, routes to `/search` or `/dashboard`
- `/search` → Manual city search (fallback when location denied)
- `/dashboard` → Main weather view

### API Integration

**Weather API:** `https://api.open-meteo.com/v1/forecast`
- Current: `temperature_2m`, `apparent_temperature`, `weather_code`
- Hourly: `temperature_2m`, `precipitation_probability`, `weather_code`
- Daily: `weather_code`, `temperature_2m_max`, `temperature_2m_min`

**Geocoding API:** `https://geocoding-api.open-meteo.com/v1/search`
- Search cities by name, returns coordinates + metadata

**WMO Weather Codes:** Mapped in-app to weather conditions and SVG assets

### Local Storage (GetStorage)

Keys used:
- `saved_locations`: JSON array of favorite cities
- Settings keys for theme/unit preferences

### Theming

- **Light Mode:** Background `#F8F9FA`, Primary `#4A90E2`
- **Dark Mode:** Background `#121212` or `#1E2124`
- Both themes explicitly defined in `lib/core/themes/app_theme.dart`
- Use `FontFeature.tabularFigures()` for numerical data to prevent jitter

## MCP Server Usage

### Project-Specific MCPs

This repository includes project-specific MCP server configurations in `.mcp.json`. Team members need to configure their environment variables locally.

### Available MCP Servers

- **context7**: Flutter/Dart docs, GetX API, package docs (pub.dev)
- **GitHub**: Remote only (issues, PRs, releases) - NOT for local git
- **Trello**: Trello board operations (cards, lists, labels, checklists)
- **Figma**: Figma design access and retrieval

### Environment Variables Setup

**IMPORTANT:** Claude Code does NOT automatically load `.env.local` files. You must load environment variables into your shell before starting Claude Code.

Copy `.env.example` to `.env.local` and fill in your values:

```bash
cp .env.example .env.local
# Edit .env.local with your actual tokens

# Then load into shell (choose one method):

# Option A: Manual loading (per session)
export $(grep -v '^#' .env.local | xargs)

# Option B: Using direnv (automatic)
echo 'dotenv .env.local' > .envrc
direnv allow

# Option C: Source in shell profile
echo "source $(pwd)/.env.local" >> ~/.bashrc  # or ~/.zshrc
```

**Required Environment Variables:**

| MCP | Variable | How to Get |
|-----|----------|------------|
| GitHub | `GITHUB_TOKEN` | https://github.com/settings/tokens (scope: repo) |
| Figma | `FIGMA_TOKEN` | Figma → Settings → Personal Access Tokens |
| Trello | `TRELLO_API_KEY` | https://trello.com/app-key |
| Trello | `TRELLO_TOKEN` | Click "Token" link on app-key page |
| Context7 | `CONTEXT7_API_KEY` | https://context7.com/dashboard (optional) |

**Important:** `.env.local` is gitignored and should never be committed.

### When to Use Each MCP

- **Context7**: Flutter framework docs, GetX API, Dart syntax, package docs (Dio, geolocator, get_storage), Material Design 3
- **GitHub**: Create/view issues/PRs on remote, view releases, manage repo metadata - **NOT** for local git operations
- **Trello**: Manage Trello cards, lists, labels, checklists; move cards between lists
- **Figma**: Access Figma designs, retrieve frame data for implementation

### MCP Configuration

The `.mcp.json` file configures all project MCPs. Environment variables are expanded using `{VAR_NAME}` syntax:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "{GITHUB_TOKEN}"
      }
    }
  }
}
```

### Additional MCPs Available Globally

- **Filesystem**: File operations, directory traversal
- **Memory**: Project patterns, user preferences across sessions

## Project Links

- **Trello Board:** https://trello.com/b/z8XwZF3U/aerosense-kanban
- **Figma Design:** https://www.figma.com/design/nbEaJycmx0bstnYhVfTJ86/AeroSense
- **GitHub Repository:** https://github.com/kmmuntasir/AeroSense

## Important Files

- `pubspec.yaml` - Dependencies and splash screen config
- `lib/main.dart` - App initialization (GetStorage, routes)
- `lib/routes/app_pages.dart` - Route definitions
- `lib/core/services/api_client.dart` - Base HTTP client with error handling
- `lib/core/themes/app_theme.dart` - Theme definitions
