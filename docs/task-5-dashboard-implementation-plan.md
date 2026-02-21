# Task 5: UI Development - Main Dashboard Implementation Plan

**Slogan:** "Making sense of the sky"
**Target:** Create the primary, glanceable weather dashboard with pull-to-refresh functionality
**Dependencies:** Tasks 3 (Controllers & Bindings) and 4 (Onboarding & Search) completed

**🎨 Figma Design Reference**: https://www.figma.com/design/nbEaJycmx0bstnYhVfTJ86/AeroSense?node-id=10-285
- Frame: "AeroSense Weather Dashboard"
- Target Device: Mobile (390x884px - iPhone 12/13/14 Pro size)

---

## 1. Design Reference (Figma)

**🎨 Figma Frame**: [AeroSense Weather Dashboard](https://www.figma.com/design/nbEaJycmx0bstnYhVfTJ86/AeroSense?node-id=10-285)
- **Frame ID**: 10-285
- **Frame Name**: "AeroSense Weather Dashboard"
- **Target Device**: Mobile phone (390px x 884px - iPhone 12/13/14 Pro)
- **Background Color**: Light mode (#F6F6F8), Dark mode (from theme)

**Parent Stories:**
- [US 2.1: Viewing Glanceable Current Weather](https://trello.com/c/mbaswrEc/28-us-21-viewing-glanceable-current-weather)
  - User wants to see critical current weather info instantly
  - Top section of screen, no scrolling required
- [US 2.1b: Manual Pull-to-Refresh](https://trello.com/c/SGlr58Tz/29-us-21b-manual-pull-to-refresh)
  - User wants to manually pull down to refresh weather data
  - Scroll to top, pull downward gesture

**Key Design Elements from Figma:**
- Clean, minimalist weather dashboard
- Large temperature display as focal point
- Weather condition icon prominently displayed
- Secondary metrics (humidity, wind, precipitation) in horizontal row
- Meaningful insights card with contextual information
- Proper spacing and typography hierarchy for readability

---

## 2. Current State Analysis

### ✅ What's Already Implemented
- **WeatherController**: Fully functional with all required reactive variables and methods
  - `currentWeather` (Rx<WeatherResponse?>)
  - `meaningInsights` (Rx<String>) - Auto-generated insights
  - `isLoading` (RxBool)
  - `errorMessage` (Rx<String>)
  - `fetchCurrentWeather()` and `refreshWeather()`
  - Temperature conversion: `convertTemperature()`, `getTemperatureWithUnit()`
  - Forecast getters: `hourlyForecast`, `dailyForecast`
  - Flight suitability: `isSuitableForFlight`, `flightSuitabilityMessage`

- **WeatherProvider**: Complete API integration
  - Open-Meteo API client with proper error handling
  - `getWeatherCodeDescription()` - WMO weather code description mapping (0-99 codes)
  - `getWindDirection()` - Wind direction to cardinal direction helper
  - Geocoding support: `searchLocation()`, `getWeatherByLocationName()`

- **Data Models**: WeatherResponse, CurrentWeather, HourlyWeather, DailyWeather
- **Theme System**: Light/Dark themes with proper color scheme
- **Routing**: Dashboard route defined in AppPages
- **Binding System**: WeatherBinding exists in lib/core/bindings/weather_binding.dart

### 🏗️ Current Dashboard Structure
- Basic placeholder implementation with "Coming Soon" text
- Location handling via Get.arguments (GeocodingResult?)
- AppBar with menu, favorite star, and settings icons (all disabled)
- Simple center layout with cloud icon
- **ISSUE**: Uses LocationBinding instead of WeatherBinding
- **ISSUE**: Contains hardcoded colors (violates no-hardcoding policy)

---

## 3. Implementation Requirements

### 3.1 DashboardView Structure (`lib/presentation/pages/dashboard/dashboard_page.dart`)

**New Requirements:**
- Change binding from LocationBinding to WeatherBinding in AppPages
- Bind to WeatherController using `Get.find<WeatherController>()`
- Implement pull-to-refresh using `RefreshIndicator`
- Create layout with proper typography hierarchy
- Implement "Meaningful Insights" card with reactive updates
- Display current weather data reactively using `Obx()`
- Remove all hardcoded colors, use theme colors only
- Use Material Icons for weather icons (SVG assets to be added in future task)

**Layout Structure:**
```dart
RefreshIndicator(
  onRefresh: () => weatherController.refreshWeather(),
  child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Glanceable Dashboard
        _buildLocationHeader(),
        _buildTemperatureDisplay(),
        _buildSecondaryDataRow(),
        _buildMeaningfulInsightsCard(),

        // Placeholder sections for future tasks:
        // Section 2: 24-Hour Forecast (Task 6)
        // Section 3: 7-Day Forecast (Task 7)
      ],
    ),
  ),
)
```

### 3.2 Typography Implementation (Based on Figma Design)

**Font Requirements:**
- **Primary Font**: Roboto (Material Design default)
- **Typography Hierarchy** (from Figma specifications):
  - Location name: `theme.textTheme.headlineMedium` (Bold, ~28-32px)
  - Current temperature: `theme.textTheme.displayLarge` (Heavy, ~96px)
  - Condition text: `theme.textTheme.headlineSmall` (Medium, ~24px)
  - Secondary data labels: `theme.textTheme.bodyMedium` (Regular, ~14px)
  - Secondary data values: `theme.textTheme.bodyLarge` (Medium, ~16px)
  - Insights: `theme.textTheme.bodyLarge` (Medium, ~16px)

**Figma Design Specifications:**
- Target screen size: 390px width (iPhone 12/13/14 Pro)
- Font family matches Material Design defaults
- Font weights follow Material Design standards

**Theme Integration (IMPORTANT - No Hardcoding Policy):**
- Use `Theme.of(context).colorScheme.*` for all colors:
  - Primary accent: `colorScheme.primary` (Indigo #4A90E2)
  - Backgrounds: `colorScheme.surface` / `colorScheme.background`
  - Text: `colorScheme.onSurface`, `colorScheme.onBackground`
  - Secondary text: `TextStyle(color: colorScheme.onSurface.withOpacity(0.7))`
- Use `theme.textTheme.*` for all typography
- Use `theme.iconTheme.color` for icon colors
- Layout primitives (Container, Padding, Row, Column) can be used directly

### 3.3 Weather Code to Icon Mapping

**Current State:**
- WeatherProvider already maps WMO codes to text descriptions via `getWeatherCodeDescription()`

**Implementation Plan:**
1. Create `lib/core/utils/weather_icons.dart` utility class
2. Map WMO codes to Material Icons for now (placeholder until custom SVG assets are created)
3. Use weather icon selector widget based on `currentWeather.current.weatherCode`

**Icon Categories (Based on WMO codes):**
- 0-3: `Icons.wb_sunny` (Clear sky)
- 45-48: `Icons.cloud` (Fog/Overcast)
- 51-57: `Icons.water_drop` (Drizzle)
- 61-67: `Icons.umbrella` (Rain)
- 71-77: `Icons.ac_unit` (Snow)
- 80-86: `Icons.grain` (Showers)
- 95-99: `Icons.thunderstorm` (Thunderstorms)

**Future Enhancement:**
- Replace Material Icons with custom SVG assets when available
- Add flutter_svg dependency when implementing SVG icons
- Create assets/icons/ directory with custom weather SVG files

### 3.4 Meaningful Insights Container

**Current State:**
- WeatherController already generates insights via `_updateMeaningInsights()`
- Insights automatically consider: temperature, humidity, wind speed, and weather conditions
- Reactive variable: `weatherController.meaningInsights`
- Auto-updates when weather data changes

**UI Requirements:**
- Card container with rounded corners
- Use `Card` widget or `Container` with `BoxDecoration`
- Background: `theme.colorScheme.surfaceVariant` or `theme.cardColor`
- Subtle border using `BorderSide(color: theme.colorScheme.outlineVariant)`
- Padding: 16px for comfortable reading
- Typography: `theme.textTheme.bodyLarge` with `FontWeight.medium`
- Icon: Leading weather condition icon for visual context

**Available Insight Data:**
```dart
// Access reactive insights
weatherController.meaningInsights

// Current condition description
weatherProvider.getWeatherCodeDescription(weatherCode)

// Individual metrics for custom insights
weatherController.currentWeather.current.temperature2M
weatherController.currentWeather.current.relativeHumidity2M
weatherController.currentWeather.current.windSpeed10M
weatherController.currentWeather.current.weatherCode
```

### 3.5 RefreshIndicator Integration

**Current State:**
- WeatherController has `refreshWeather()` method that calls `fetchCurrentWeather()`
- `isLoading` reactive variable tracks loading state

**Implementation:**
```dart
RefreshIndicator(
  onRefresh: () => weatherController.refreshWeather(),
  color: theme.colorScheme.primary,  // Use theme color
  backgroundColor: theme.colorScheme.surface,
  child: SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),  // Enable pull-to-refresh
    child: // your content here
  ),
)
```

**Loading States:**
- `Obx(() => weatherController.isLoading)` for reactive loading indicator
- Show loading overlay or indicator during initial fetch
- RefreshIndicator automatically shows spinner during refresh
- Handle error states: `weatherController.errorMessage`

### 3.6 Layout Spacing (Based on Figma Design)

**Figma Spacing Specifications:**
- Screen width: 390px (mobile design target)
- Container padding: 16px (all sides)
- Section spacing: 16px vertical
- Card padding: 16px
- Icon spacing: 8-12px horizontal
- Weather icon size: 80px for current weather
- Secondary icon sizes: 32-48px

**Standard Flutter Spacing Values:**
```dart
// Container padding
EdgeInsets.all(16)

// Section spacing
EdgeInsets.symmetric(vertical: 16)

// Icon spacing
SizedBox(width: 8) or SizedBox(width: 12)

// Card padding
EdgeInsets.all(16)

// Weather icon
Icon(Icons.wb_sunny, size: 80)
```

---

## 4. Detailed Implementation Steps

### Step 1: Update Route Binding (lib/routes/app_pages.dart)
**Current:**
```dart
GetPage(
  name: '/dashboard',
  page: () => const DashboardPage(),
  binding: LocationBinding(),  // ❌ Wrong binding
  transition: Transition.cupertino,
),
```

**Change to:**
```dart
GetPage(
  name: '/dashboard',
  page: () => const DashboardPage(),
  binding: WeatherBinding(),  // ✅ Correct binding
  transition: Transition.cupertino,
),
```

Add import: `import '../core/bindings/weather_binding.dart';`

### Step 2: Create Weather Icon Utility (lib/core/utils/weather_icons.dart)
```dart
import 'package:flutter/material.dart';

class WeatherIcons {
  static IconData getIcon(int weatherCode) {
    switch (weatherCode) {
      case 0:
      case 1:
        return Icons.wb_sunny;  // Clear sky
      case 2:
      case 3:
        return Icons.cloud;  // Partly cloudy / Overcast
      case 45:
      case 48:
        return Icons.cloud;  // Fog
      case 51:
      case 53:
      case 55:
        return Icons.water_drop;  // Drizzle
      case 61:
      case 63:
      case 65:
        return Icons.umbrella;  // Rain
      case 71:
      case 73:
      case 75:
      case 77:
        return Icons.ac_unit;  // Snow
      case 80:
      case 81:
      case 82:
        return Icons.grain;  // Rain showers
      case 85:
      case 86:
        return Icons.ac_unit;  // Snow showers
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm;  // Thunderstorm
      default:
        return Icons.help_outline;  // Unknown
    }
  }
}
```

### Step 3: Build DashboardView Components

**Component 1: Location Header**
```dart
Widget _buildLocationHeader(BuildContext context) {
  final location = Get.arguments as GeocodingResult?;
  final theme = Theme.of(context);

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Icon(Icons.location_on, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          location?.name ?? 'Current Location',
          style: theme.textTheme.headlineMedium,
        ),
      ],
    ),
  );
}
```

**Component 2: Temperature Display**
```dart
Widget _buildTemperatureDisplay(BuildContext context) {
  final controller = Get.find<WeatherController>();
  final theme = Theme.of(context);

  return Obx(() {
    final temp = controller.currentWeather?.current.temperature2M ?? 0;
    final weatherCode = controller.currentWeather?.current.weatherCode ?? 0;
    final displayTemp = controller.getTemperatureWithUnit(temp);

    return Column(
      children: [
        Icon(
          WeatherIcons.getIcon(weatherCode),
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          displayTemp,
          style: theme.textTheme.displayLarge,
        ),
        Text(
          weatherController.getWeatherCodeDescription(weatherCode),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  });
}
```

**Component 3: Secondary Data Row**
```dart
Widget _buildSecondaryDataRow(BuildContext context) {
  final controller = Get.find<WeatherController>();
  final theme = Theme.of(context);

  return Obx(() {
    final weather = controller.currentWeather?.current;
    if (weather == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSecondaryItem(
            context,
            Icons.water_drop,
            'Humidity',
            '${weather.relativeHumidity2M?.toInt() ?? 0}%',
          ),
          _buildSecondaryItem(
            context,
            Icons.air,
            'Wind',
            '${weather.windSpeed10M?.toInt() ?? 0} m/s',
          ),
          _buildSecondaryItem(
            context,
            Icons.umbrella,
            'Precipitation',
            '${weather.precipitation?.toStringAsFixed(1) ?? '0.0'} mm',
          ),
        ],
      ),
    );
  });
}
```

**Component 4: Meaningful Insights Card**
```dart
Widget _buildMeaningfulInsightsCard(BuildContext context) {
  final controller = Get.find<WeatherController>();
  final theme = Theme.of(context);

  return Obx(() {
    final insights = controller.meaningInsights;
    final weatherCode = controller.currentWeather?.current.weatherCode ?? 0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              WeatherIcons.getIcon(weatherCode),
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                insights,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  });
}
```

### Step 4: Implement Pull-to-Refresh
Wrap the entire scrollable content in RefreshIndicator (see Layout Structure in 2.1)

### Step 5: Remove Hardcoded Colors
- Replace all `Color(0xFF4A90E2)` with `theme.colorScheme.primary`
- Replace all `Color(0xFF121212)` with `theme.colorScheme.onSurface`
- Replace all `Colors.white70` with `theme.colorScheme.onSurface.withOpacity(0.7)`
- Use theme colors for all UI elements

### Step 6: Handle Loading and Error States
```dart
Widget _buildLoadingState() {
  return const Center(child: CircularProgressIndicator());
}

Widget _buildErrorState(BuildContext context, String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
```

### Step 7: Initialize Weather Data
In DashboardPage build method or onInit, call:
```dart
@override
void initState() {
  super.initState();
  // Fetch weather when page loads
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.find<WeatherController>().fetchCurrentWeather();
  });
}
```

---

## 5. Key Dependencies & Resources Needed

### 8.1 Current Dependencies
✅ All required dependencies already in pubspec.yaml:
- `get: ^4.6.6` - State management
- `dio: ^5.4.0` - HTTP client
- `geolocator: ^14.0.2` - Location services
- `permission_handler: ^12.0.1` - Permissions
- `get_storage: ^2.1.1` - Local storage

### 8.2 Future Dependencies (Not Required for This Task)
The following will be needed when implementing custom SVG icons:
```yaml
# Add when implementing custom weather icons
flutter_svg: ^2.0.9
```

### 8.3 Icon Assets (Future Enhancement)
Custom SVG icons can be added later in `assets/icons/`:
- `sunny.svg` - Clear sky conditions
- `partly-cloudy.svg` - Partly cloudy
- `cloudy.svg` - Overcast
- `rain.svg` - Rain
- `snow.svg` - Snow
- `thunderstorm.svg` - Thunderstorms
- `fog.svg` - Fog

### 6.4 Theme Colors (Use via Theme.of(context))
- `colorScheme.primary` - #4A90E2 (Indigo - Sky accent)
- `colorScheme.background` - #F8F9FA (Light mode) / #121212 (Dark mode)
- `colorScheme.surface` - Card/surface background
- `colorScheme.onSurface` - Primary text color
- `colorScheme.onSurface.withOpacity(0.7)` - Secondary text
- `colorScheme.error` - Error states

---

## 6. Testing Strategy

### 8.1 Unit Tests (test/unit/)
- Test WeatherIcon utility `getIcon()` method with all WMO codes
- Test temperature conversion with different units
- Test insight generation logic in WeatherController
- Mock WeatherProvider for isolated testing

### 8.2 Widget Tests (test/widget/)
Test DashboardPage widget:
```dart
testWidgets('Dashboard displays loading state', (tester) async {
  // Mock WeatherController in loading state
  // Verify CircularProgressIndicator is shown
});

testWidgets('Dashboard displays weather data', (tester) async {
  // Mock WeatherController with data
  // Verify temperature, location, and insights display
});

testWidgets('Dashboard handles error state', (tester) async {
  // Mock WeatherController with error
  // Verify error message displays
});

testWidgets('RefreshIndicator triggers refresh', (tester) async {
  // Test pull-to-refresh gesture
  // Verify refreshWeather() is called
});
```

### 8.3 Integration Tests
- Test complete flow from onboarding → dashboard
- Test weather data fetch from API
- Test location passing via Get.arguments
- Test theme switching affects dashboard colors

### 6.4 Test Data
Create test fixtures in `test/fixtures/`:
- `mock_weather_response.dart` - Sample WeatherResponse
- Test with various WMO codes (0, 3, 45, 61, 95)
- Test edge cases: null data, zero values, extreme temperatures

---

## 7. Success Criteria

### 8.1 Functional Requirements
✅ Dashboard displays current weather data reactively (via Obx)
✅ Pull-to-refresh works correctly with RefreshIndicator
✅ Meaningful insights card displays auto-generated insights
✅ Temperature unit conversion displays correctly (°C/°F)
✅ Theme switching properly affects all colors
✅ Location name displays correctly from Get.arguments
✅ Loading states show during data fetch
✅ Error states display properly with messages

### 8.2 Visual Requirements
✅ Typography hierarchy implemented correctly using theme.textTheme
✅ Weather icons display properly using Material Icons
✅ Cards use proper theme colors (no hardcoded colors)
✅ Loading states shown appropriately
✅ Responsive design works on different screen sizes
✅ Proper spacing and padding throughout

### 8.3 Code Quality Requirements
✅ No hardcoded colors (except layout primitives)
✅ Proper use of GetX reactive patterns (Obx, Rx variables)
✅ WeatherController dependency properly injected via WeatherBinding
✅ Follows Flutter best practices and Clean Architecture
✅ Widget tests written for major components
✅ Proper error handling with user-friendly messages

---

## 8. Future Considerations

### 8.1 Extension Points
- Replace Material Icons with custom SVG icons (add flutter_svg dependency)
- Add hourly forecast section (Task 6)
- Add daily forecast section (Task 7)
- Weather icon animations (future enhancement)
- Background effects based on weather conditions
- More sophisticated insight generation (e.g., time-based, clothing suggestions)

### 8.2 Code Organization
- Extract reusable components (WeatherCard, InsightCard, WeatherIcon)
- Create separate widgets for each section if they grow complex
- Document the weather icon mapping system
- Consider creating weather-specific theme extensions

### 8.3 Performance Optimizations
- Optimize widget rebuilds with const constructors
- Consider cached network images for weather icons if using SVG
- Lazy loading for future forecast sections
- Debounce rapid refresh gestures

### 8.4 Known Limitations
- Using Material Icons as placeholders (not custom SVG icons)
- No hourly/daily forecast sections (separate tasks)
- Basic insights generation (can be enhanced later)
- No weather animations (future enhancement)

---

**Implementation Priority**: High - This is the core MVP feature that users interact with daily

**Estimated Effort**: 6-8 hours

**No Additional Dependencies Required** - Uses existing packages and Material Icons

**Branch Name**: `feature/AERO-5-main-dashboard-ui`

**Files to Modify**:
- lib/routes/app_pages.dart
- lib/presentation/pages/dashboard/dashboard_page.dart
- lib/core/utils/weather_icons.dart (new file)
- test/widget/dashboard_page_test.dart (new file)