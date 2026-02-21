# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**AeroSense** is a modern Flutter weather dashboard that delivers real-time weather conditions, 5-day forecasts, and air quality metrics. The app uses the Open-Meteo API (no API key required) for weather data.

- **Framework**: Flutter (Dart SDK ^3.10.8)
- **State Management & Routing**: GetX (^4.6.6)
- **HTTP Client**: Dio (^5.4.0)
- **Location**: Geolocator (^14.0.2) + Permission Handler (^12.0.1)
- **Storage**: GetStorage (^2.1.1)
- **Project Slug**: AERO (used in branch names, commit messages, ticket references)

## Development Commands

### Build and Run
```bash
flutter pub get              # Install dependencies
flutter run                  # Run in debug mode
flutter build apk           # Build Android APK
flutter build ios           # Build iOS app
```

### Code Quality
```bash
flutter analyze              # Static analysis
dart format .               # Format code
dart fix --apply            # Apply automated fixes
flutter test                # Run all tests
flutter test --coverage     # Run with coverage report
flutter test test/unit/my_test.dart  # Run specific test file
```

### Splash Screen Generation
```bash
flutter pub run flutter_native_splash:create
```

## Architecture

### Clean Architecture Pattern

The codebase follows a clean architecture with these layers:

```
lib/
├── main.dart              # App entry point
├── core/                  # Shared business logic
│   ├── bindings/          # GetX dependency injection
│   ├── controllers/       # State management (GetX)
│   ├── models/            # Data models (JSON serialization)
│   ├── services/          # API clients, providers
│   └── themes/            # App theming (light/dark)
├── domain/                # Domain layer (use cases, entities, repositories)
├── data/                  # Data layer (datasources, repository implementations)
├── presentation/          # UI layer
│   ├── bindings/          # Page-level bindings
│   └── pages/             # Screens (onboarding, dashboard, search, home)
├── routes/                # Navigation configuration (AppPages)
└── services/              # Additional services
```

### Key Concepts

**GetX State Management**:
- Controllers extend `GetxController` and use `Rx<T>` reactive variables
- Bindings use `Get.lazyPut()` for lazy initialization
- Retrieve controllers with `Get.find<ControllerType>()`
- Use `Obx()` for reactive UI updates
- Never create controllers inside `build()` methods

**Routing**:
- Named routes defined in `lib/routes/app_pages.dart`
- Navigate with `Get.toNamed('/route')`, `Get.offNamed('/route')`
- Pass arguments: `Get.toNamed('/route', arguments: {'key': value})`
- Access arguments: `final args = Get.arguments as Map`

**API Integration**:
- Base URL: `https://api.open-meteo.com`
- Weather API: `/v1/forecast` (current, hourly, daily data)
- Geocoding API: `/v1/search` (location search)
- `ApiClient` class wraps Dio with error handling (`ApiException`)

**Location & Permissions**:
- `LocationController` handles GPS, permissions, and saved locations
- Use `Permission.location.request()` for permission requests
- Handle permanently denied: direct user to app settings
- Store favorites in GetStorage under `saved_locations` key

## Code Style Guidelines

### Naming Conventions
- **Files**: `snake_case.dart` (e.g., `weather_controller.dart`)
- **Classes**: `PascalCase` (e.g., `WeatherController`, `DashboardPage`)
- **Variables/Methods**: `camelCase` (e.g., `currentWeather`, `fetchData()`)
- **Private members**: Prefix with `_` (e.g., `_isLoading`, `_privateMethod()`)
- **Controllers**: PascalCase with `Controller` suffix
- **Bindings**: PascalCase with `Binding` suffix
- **Pages**: PascalCase with `Page` suffix

### No Hardcoding Policy
Nothing in pages/widgets should be hardcoded:
- **Strings**: Use constants or localization
- **Colors**: Use `Theme.of(context).colorScheme.*`
- **Dimensions**: Use named constants
- **Style**: Never hardcode colors like `"#4A90E2"`

Layout primitives (`Container`, `Padding`, `Row`, `Column`, `Stack`, `ListView`) can be used directly.

### Import Organization
```dart
// 1. Dart SDK imports
// 2. Flutter framework imports
// 3. Package imports (alphabetical)
// 4. Project imports (relative, grouped by feature)
```

### Controller Pattern
```dart
class MyController extends GetxController {
  final RxBool _isLoading = RxBool(false);
  final RxString _errorMessage = RxString('');

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    // Initialize
  }

  @override
  void onClose() {
    // Cleanup (dispose streams, timers)
    super.onClose();
  }
}
```

### Widget Pattern
```dart
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final controller = Get.find<MyController>();
        // UI
      }),
    );
  }
}
```

## Task Workflow

When given a task to implement, follow this workflow:

1. **Gather Requirements**: Read the relevant Jira/Trello card description and comments. If requirements are unclear, ask the user for clarification.

2. **Figma Integration**: If the task involves a Figma frame (link may be in card description), use the Figma MCP server to retrieve frame data.

3. **Create Branch**: Tasks must be worked on in their own branches. Never work on `main` or `dev` branches. Follow the branch naming convention (see Git Workflow below).

4. **Create Plan**: Analyze the codebase and create a step-by-step implementation plan. Write the plan to a file in the `./docs` folder.

5. **Get Approval**: Present the plan to the user and wait for explicit confirmation. **DO NOT start implementation without approval.**

6. **Implement**: After user approval:
   - Move the Jira/Trello card to "In Progress" status
   - Create a todo list tracking the implementation steps
   - Implement step-by-step

7. **Test**: Write relevant unit, widget, and integration tests.

8. **Commit & Push**: Commit changes following git guidelines, then push to remote.

9. **Complete**: Move the Jira/Trello card to "In Review" status and summarize changes to the user.

## Git Workflow

### Branch Naming
Format: `type/AERO-TICKET_NUMBER-hyphenated-description`
- Examples: `feature/AERO-123-add-location-search`, `bugfix/AERO-234-fix-permission-crash`
- Release branches: `release/1.2.3` (version number only)
- If no ticket number, omit it: `feature/add-location-search`

### Commit Messages
- Format: `AERO-TICKET_NUMBER: message` (single line)
- Example: `AERO-123: Add location permission handling`
- Extract ticket number from branch name
- If no ticket, omit prefix

### Sacred Rule
NEVER run a git command without user's explicit approval.

## Testing

### Test Structure
```
test/
├── unit/          # Controllers, services, models
├── widget/        # Pages, custom widgets
└── integration/   # End-to-end flows
```

### Key Testing Patterns
- Use `mocktail` for mocking (no code generation)
- Set `Get.testMode = true` in setUp
- Use `Get.reset()` in tearDown
- Use AAA pattern: Arrange, Act, Assert
- Widget tests: use `pumpAndSettle()` after async operations

### Running Tests
```bash
flutter test                          # All tests
flutter test test/unit/my_test.dart   # Specific file
flutter test --coverage               # With coverage
```

## Project-Specific Notes

### Theme Configuration
- Light mode: Background `#F8F9FA`
- Dark mode: Background `#121212`
- Primary accent: Indigo `#4A90E2`
- Use `Theme.of(context).colorScheme.primary` for theming

### Onboarding Flow
The app starts at `/onboarding` which:
1. Checks location permission status
2. Routes to `/search` if permission denied
3. Routes to `/dashboard` if permission granted
4. Uses `OnboardingBinding` for dependency injection

### WMO Weather Codes
The app maps WMO weather codes (0-99) to display appropriate weather icons and descriptions. This mapping should be centralized in utilities.

### Common Packages
- `get` - State management, routing, DI
- `dio` - HTTP client with interceptors
- `geolocator` - GPS coordinates
- `permission_handler` - Runtime permissions
- `get_storage` - Fast key-value storage
- `flutter_native_splash` - Splash screen generation
