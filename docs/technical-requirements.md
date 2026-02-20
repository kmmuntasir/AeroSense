# Technical Requirements Document (TRD)

**Product Name:** AeroSense (MVP)
**Framework:** Flutter (Latest Version)
**State Management & Routing:** GetX
**Data Provider:** Open-Meteo API (Free, no API key)

---

## 1. System Architecture & GetX Implementation

### 1.1 Project Structure
The application will utilize a feature-first architectural pattern heavily leveraging the **GetX** ecosystem.
*   **`lib/app/`**: Core application setup (`GetMaterialApp`, themes, global bindings).
*   **`lib/data/`**: API providers, models, and local storage services.
*   **`lib/modules/`**: Feature modules containing their respective `View`, `Controller`, and `Binding`.
    *   `dashboard/` (Current weather, 24h forecast, 7-day outlook)
    *   `search/` (City search and saved locations)
*   **`lib/core/`**: Shared constants, theme definitions, WMO code mappings, and utilities.

### 1.2 State Management (GetX)
*   **Reactive State:** `Rx` variables (`.obs`) will be used for weather data, loading states, and location permissions to ensure the UI updates instantly when data changes.
*   **Controllers:** 
    *   `WeatherController`: Fetches and stores weather data for a given location, computes the "Meaningful Insights" string.
    *   `LocationController`: Handles GPS permission requests, current coordinates, and saved favorite cities.
*   **Dependency Injection:** `Get.lazyPut()` within `Bindings` to initialize API services and controllers only when needed.
*   **Routing:** Named routes mapped in `GetMaterialApp` using `GetPage`.

---

## 2. API Integration (Open-Meteo)

The app requires two specific APIs from Open-Meteo:

### 2.1 Weather API
*   **Base URL:** `https://api.open-meteo.com/v1/forecast`
*   **Required Query Parameters:**
    *   `latitude`, `longitude` (Dynamic based on user/search)
    *   `current`: `temperature_2m,apparent_temperature,weather_code`
    *   `hourly`: `temperature_2m,precipitation_probability,weather_code`
    *   `daily`: `weather_code,temperature_2m_max,temperature_2m_min`
    *   `temperature_unit`: `fahrenheit` or `celsius` (default unit based on locale or preference)
    *   `timezone`: `auto`

### 2.2 Geocoding API (Location Search)
*   **Base URL:** `https://geocoding-api.open-meteo.com/v1/search`
*   **Required Query Parameters:**
    *   `name`: User input string
    *   `count`: Limit results (e.g., 10)
    *   `language`: `en`
    *   `format`: `json`

### 2.3 Data Processing & "Meaningful Insights"
*   The `WeatherController` will include logic to parse the `hourly` data array to generate the dynamic 1-2 sentence text block (e.g., finding the first hour where `precipitation_probability > 0` to state "Rain expected around [Time]").
*   WMO Weather Codes (0-99) will be mapped to a local `enum` or utility map returning the correct SVG asset path.

---

## 3. UI/UX Implementation Requirements

### 3.1 Theming
*   **Theme Engine:** `ThemeData` applied via `Get.changeTheme()`. Both Light and Dark themes must be explicitly defined.
*   **Colors:**
    *   *Light Mode Background:* `#F8F9FA`
    *   *Dark Mode Background:* `#121212` or `#1E2124`
    *   *Primary Accent:* Indigo `#4A90E2`
*   **Typography:**
    *   Use `google_fonts` package (e.g., `GoogleFonts.inter()` or `GoogleFonts.plusJakartaSans()`).
    *   Enable `FontFeature.tabularFigures()` for numerical data (temperatures, timelines) to prevent UI jittering.
    *   **Current Temp:** > 80dp, potentially bold/condensed.

### 3.2 Key UI Components
*   **Dashboard View:**
    *   Sliver App Bar or flexible header for the "Glanceable" Current Weather.
    *   Horizontal `ListView.builder` for the 24-hour timeline.
    *   Vertical `ListView.builder` or Column for the 7-day outlook.
*   **Search & Favorites View:**
    *   Debounced `TextField` for triggering Geocoding API calls.
    *   `ListView` holding saved locations.
*   **Assets:**
    *   Vector (`.svg`) assets rendered using `flutter_svg` for crisp, resolution-independent weather icons.

---

## 4. Local Storage & Device Capabilities

### 4.1 Device Location
*   **Package:** `geolocator` or `location`.
*   Requires `ACCESS_COARSE_LOCATION` and `ACCESS_FINE_LOCATION` in AndroidManifest.xml.
*   Requires `NSLocationWhenInUseUsageDescription` in Info.plist.

### 4.2 Local Persistence
*   **Package:** `get_storage` (Recommended due to GetX ecosystem) or `shared_preferences`.
*   **Data to store:**
    *   List of Favorite Cities (JSON array of `LocationModel` containing Name, Lat, Lng).
    *   Last fetched weather data (optional, for offline caching).
    *   User settings (Theme preference, unit preference).

---

## 5. Third-Party Packages Required

Ensure the following are added to `pubspec.yaml`:
*   `get`: State management, routing, DI.
*   `dio` or `http`: For robust API requests.
*   `geolocator`: GPS coordinate retrieval.
*   `get_storage`: Key/value pair local storage.
*   `google_fonts`: Dynamic typography.
*   `flutter_svg`: Rendering of vector weather icons.
*   `intl`: Date and time formatting (converting API timestamps to readable hours/days).

---

## 6. Out of Scope Definitions (Technical)
*   No WebSocket connections or real-time streaming APIs.
*   No Firebase integration (No Auth, Firestore, or Cloud Messaging).
*   No background location tracking (location is only fetched when app is active).
*   No complex mapping libraries (e.g., `google_maps_flutter`).
