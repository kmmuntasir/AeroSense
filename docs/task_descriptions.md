# AeroSense MVP Task Descriptions

This document breaks down the user stories and requirements into actionable, technical tasks for development. Each task is detailed to provide clear instructions for implementation, along with explicit dependencies.

---

## Task 1: Project Setup & Foundation

**Description:** Initialize the Flutter environment and fundamental project architecture. This lays the groundwork for all subsequent feature development.

**Dependencies:** None.

**Action Items:**
*   Initialize a new Flutter project named `aero_sense`.
*   Configure the core directory structure (`lib/app/`, `lib/data/`, `lib/modules/`, `lib/core/`).
*   Update `pubspec.yaml` with the required dependencies:
    *   `get` (State Management, Routing)
    *   `dio` or `http` (Networking)
    *   `geolocator` (Location Services)
    *   `get_storage` (Local Persistence)
    *   `google_fonts` (Typography)
    *   `flutter_svg` (Vector rendering)
    *   `intl` (Date formatting)
    *   `flutter_launcher_icons` (App Icon generation)
    *   `flutter_native_splash` (Native launch screen generation)
*   Configure native permissions for location:
    *   Android (`AndroidManifest.xml`): `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`.
    *   iOS (`Info.plist`): `NSLocationWhenInUseUsageDescription`.
*   Configure and generate native assets:
    *   Set up `flutter_launcher_icons.yaml` and generate icons.
    *   Set up `flutter_native_splash.yaml` with brand background color/logo and generate splash screens.
*   Initialize `GetStorage` in the `main.dart` execution flow.
*   Setup initial `GetMaterialApp` configuration with basic light/dark theme placeholders.

---

## Task 2: Core Data Services Implementation

**Description:** Build the networking layer to communicate with the Open-Meteo API and manage robust data fetching.

**Dependencies:** Completion of Task 1.

**Action Items:**
*   Create a base API client (using Dio or http) configured with timeout settings.
*   Implement the `WeatherProvider` to interact with `https://api.open-meteo.com/v1/forecast`:
    *   Construct the query string correctly using dynamic latitude/longitude parameters.
    *   Extract necessary data nodes (current temperature, apparent temp, weather codes, hourly/daily forecasts).
*   Implement the `GeocodingProvider` to interact with `https://geocoding-api.open-meteo.com/v1/search`:
    *   Construct queries to return city search results.
*   Create Dart data models (e.g., `WeatherResponse`, `DailyForecast`, `HourlyForecast`, `CitySearchResult`) using `json_serializable` or manual fromJson methods.
*   Implement basic error handling for network failures or API rate limits.

---

## Task 3: State Management Setup (Controllers & Bindings)

**Description:** Architect the reactive bridge between the UI and the Data services using GetX.

**Dependencies:** Completion of Task 2.

**Action Items:**
*   **LocationController:**
    *   Implement logic to request and verify location permissions using `geolocator`.
    *   Implement method to retrieve current device coordinates.
    *   Manage an `RxList<CitySearchResult>` for saved favorite locations, integrated with `GetStorage` for persistence.
*   **WeatherController:**
    *   Create an `isLoading` reactive boolean.
    *   Implement a primary `fetchWeather(double lat, double lng)` method that calls the `WeatherProvider`.
    *   Create reactive variables (`Rx<WeatherResponse>`) to hold the fetched data.
    *   Implement the algorithm to generate the "Meaningful Insights" string.
*   **SettingsController:**
    *   Manage an `RxBool` or `Rx<TemperatureUnit>` for the Celsius/Fahrenheit toggle.
    *   Initialize this value from `GetStorage` on startup.
    *   Create a method to toggle the unit and save the new preference to `GetStorage`.
*   **Bindings:** Create initial GetX bindings (e.g., `InitialBinding`, `DashboardBinding`, `SettingsBinding`) to inject these controllers.

---

## Task 4: UI Development - Onboarding & Fallback

**Description:** Build the user experience for the first launch, specifically handling location capability states.

**Dependencies:** Completion of Task 3.

**Action Items:**
*   Create the initial app loading view (Splash screen or a clean loading indicator).
*   Integrate the native location permission prompt flow managed by `LocationController`.
*   Implement routing logic based on the permission response:
    *   If granted: Trigger the main weather fetch and transition to the Dashboard View.
    *   If denied: Transition to the "Empty State / Manual Search" View guiding the user.
*   Ensure smooth UX transitions between these states avoiding abrupt jumps.

---

## Task 5: UI Development - Main Dashboard (Current Weather)

**Description:** Construct the primary, glanceable focal point of the application based on the design guidelines.

**Dependencies:** Completion of Tasks 3 and 4.

**Action Items:**
*   Create the `DashboardView` structure.
*   Implement Typography styling referencing `GoogleFonts` and enabling `tabularFigures`.
*   Bind the UI to the `WeatherController` to reactively display:
    *   Current Location Name.
    *   Large Current Temperature (respecting the `SettingsController` unit preference).
    *   Weather condition text description.
    *   "Feels Like", High, and Low temperatures (respecting unit preference).
*   Implement the UI container for the "Meaningful Insights" string.
*   Implement logic to dynamically map the Open-Meteo WMO weather code to SVG icon assets.
*   **Pull-to-Refresh:** Wrap the primary scrollable view (containing the dashboard and forecasts) in a `RefreshIndicator` widget, binding its `onRefresh` callback to the `WeatherController.fetchWeather()` method.

---

## Task 6: UI Development - Hourly Forecast

**Description:** Build the scrollable 24-hour forecast timelines.

**Dependencies:** Completion of Task 5.

**Action Items:**
*   Implement a horizontal `ListView.builder`.
*   Format API timestamps into readable hours (e.g., "3 PM") using the `intl` package.
*   Display hour, icon, temperature, and precipitation chance (conditionally shown if > 0%).
*   Ensure the list view updates reactively based on data from the `WeatherController`.

---

## Task 7: UI Development - Daily Forecast

**Description:** Build the vertical 7-day outlook.

**Dependencies:** Completion of Task 5 (Can be done in parallel with Task 6).

**Action Items:**
*   Implement a vertical `ListView.builder` or static `Column` below the 24-hour section.
*   Format dates into day names (e.g., "Mon", "Tue").
*   Display the day name, icon, and the daily high/low temperatures.
*   Ensure the list updates reactively based on data from the `WeatherController`.

---

## Task 8: UI Development - Search 

**Description:** Build the Geocoding search UI to allow users to find different cities.

**Dependencies:** Completion of Task 3.

**Action Items:**
*   Implement a `TextField` with debouncing (e.g., wait 500ms after typing stops before calling the API) to prevent hitting rate limits during typing.
*   Bind the text input to the Geocoding API via the controller to fetch results.
*   Display a list of autocomplete suggestions (City, Region/Country).
*   Navigate immediately to the selected city's dashboard upon selection.

---

## Task 9: UI Development - Locations Management

**Description:** Build the Saved Locations Hub and favorite toggling functionality.

**Dependencies:** Completion of Tasks 3 and 8.

**Action Items:**
*   **Locations Hub View:**
    *   Create a dedicated screen/drawer for saved cities.
    *   Bind to the `LocationController`'s `savedCities` RxList.
    *   Implement a `ListView` displaying each saved city with its summary weather data (City Name, Temp, Icon).
    *   Implement swipe-to-delete functionality.
*   **Favorites Toggle:**
    *   Implement the "Add to Favorites" toggle button on the dashboard header.
    *   Ensure the toggle synchronizes with the `LocationController` and `GetStorage` to persist the data.

---

## Task 10: UI Development - Settings

**Description:** Build the user interface for managing app preferences.

**Dependencies:** Completion of Task 3.

**Action Items:**
*   Create a clean, simple `SettingsView` (accessible via the app bar or a drawer).
*   Implement a toggle switch or segmented button for selecting the Temperature Unit (°C vs °F).
*   Bind the UI toggle to the `SettingsController` to update the reactive state and save to local storage.
*   *(Optional but recommended)* Implement a similar switch for Theme Selection (Light/Dark/System).
