# User Stories & Task Definitions

**Product:** AeroSense (MVP)

---

## Epic 1: Onboarding & First Launch

### User Story 1.1: Requesting Location Permission
**As a** new user launching the app for the first time,
**I want** to be prompted to grant location access,
**So that** the app can automatically fetch and display the weather for my current location.

*   **Interaction & Steps:**
    1.  User opens the installed app from their device home screen.
    2.  The app displays a native OS permission dialog requesting "Location Access" (e.g., "Allow AeroSense to access this device's location?").
*   **Outcome:** The system registers the user's choice (Grant or Deny).
*   **Change in App's View:** 
    *   *If Granted:* The app transitions to a loading state (e.g., a subtle spinner) while fetching coordinates and API data, then smoothly transitions to the "Dashboard View" displaying local weather.
    *   *If Denied:* The app transitions to an initial empty "Search View" or a specific onboarding screen prompting the user to manually search for a city to get started.

### User Story 1.2: Manual Initial City Search (Location Denied)
**As a** user who denied location access on first launch,
**I want** to manually search for a city,
**So that** I can see the weather without sharing my GPS coordinates.

*   **Interaction & Steps:**
    1.  User sees an empty state or onboarding screen instructing them to search.
    2.  User taps the provided "Search Bar". Device keyboard appears.
    3.  User types a city name (e.g., "London").
    4.  User sees a dropdown/list of matching results from the Geocoding API.
    5.  User taps on the desired city from the results.
*   **Outcome:** The app saves the selected city as the primary location temporarily (or permanently in favorites). The app fetches weather data for that city.
*   **Change in App's View:** The app transitions from the Search View/Onboarding instantly to the main "Dashboard View", populated with the selected city's weather data.

---

## Epic 2: The Core Weather Dashboard

### User Story 2.1: Viewing Glanceable Current Weather
**As a** user opening the app for my daily check,
**I want** to see the most critical current weather information instantly,
**So that** I can make immediate decisions (e.g., what to wear).

*   **Interaction & Steps:**
    1.  User opens the app (subsequent launches).
    2.  User views the top section of the screen (no scrolling required).
*   **Outcome:** User absorbs the current weather state within 1-2 seconds.
*   **Change in App's View:** The dashboard prominently displays:
    *   City Name (e.g., "New York").
    *   Current Temperature (very large, e.g., "72°").
    *   Text condition ("Partly Cloudy") and a corresponding visual Icon.
    *   "Feels Like" temperature, and Today's High/Low.
    *   **Meaningful Insights Block:** A dynamically generated sentence (e.g., "Rain expected around 3:00 PM."). The background color of the UI may subtly reflect the current condition (e.g., warm tones for hot weather).

### User Story 2.1b: Manual Pull-to-Refresh
**As a** user who has had the app open for a while,
**I want** to manually pull down on the dashboard,
**So that** I can force the app to fetch the absolute latest weather data.

*   **Interaction & Steps:**
    1.  User scrolls to the top of the dashboard.
    2.  User continues to pull downward (swipe down gesture) on the screen.
*   **Outcome:** A native refresh indicator spins, indicating an API call is in progress.
*   **Change in App's View:** The latest data immediately populates the dashboard, 24-hour, and 7-day views, and the refresh indicator disappears.

### User Story 2.2: Viewing the 24-Hour Short-Term Forecast
**As a** user planning my day,
**I want** to see an hourly breakdown of the weather,
**So that** I know when conditions will change (e.g., when rain starts/stops).

*   **Interaction & Steps:**
    1.  User looks just below the current weather dashboard.
    2.  User swipes horizontally left and right on the timeline.
*   **Outcome:** User sees the temperature and condition trajectory for the next 24 hours.
*   **Change in App's View:** A horizontal scrolling list (`ListView.builder` in Flutter) moves smoothly. Each visible item displays the Hour (e.g., "2 PM"), a condition icon, temperature, and precipitation chance (if >0%).

### User Story 2.3: Viewing the 7-Day Outlook
**As a** user planning my upcoming week,
**I want** to see the forecast for the next several days,
**So that** I can plan activities ahead of time.

*   **Interaction & Steps:**
    1.  User scrolls vertically down the main dashboard page, past the 24-hour forecast.
*   **Outcome:** User can determine the high-level weather trend for the week.
*   **Change in App's View:** A vertical list or grid appears below the hourly timeline. Each row/item displays the Day Name (e.g., "Mon"), a condition icon, and the expected High and Low temperatures for that day.

---

## Epic 3: Location Management & Search

### User Story 3.1: Accessing Saved Locations Hub
**As a** user,
**I want** to access a specific area where my saved cities are listed,
**So that** I can easily switch between different locations I care about.

*   **Interaction & Steps:**
    1.  User taps a prominently placed "Locations" or "Menu" icon (e.g., top left or top right app bar icon).
*   **Outcome:** The app retrieves the saved locations from local storage.
*   **Change in App's View:** The screen transitions (e.g., slides up, or opens a side drawer) to the "Saved Locations List". This view displays cards/rows for each saved city, showing summary data: City Name, Current Temp, Icon, and Local Time.

### User Story 3.2: Searching for a New Location
**As a** user in the Locations Hub,
**I want** to search for a new city worldwide,
**So that** I can check its weather or add it to my list.

*   **Interaction & Steps:**
    1.  User taps a "Search" floating action button or search bar at the top of the Locations view.
    2.  User types a query (e.g., "Tokyo").
    3.  A debounced API call fetches autocomplete/search results.
    4.  User selects a city from the populated list.
*   **Outcome:** The app fetches the detailed weather data for the newly selected city.
*   **Change in App's View:** The view navigates to a localized version of the "Dashboard View" for that specific city. The navigation stack may show a "Back" button to return to the Locations list.

### User Story 3.3: Adding/Removing a Favorite Location
**As a** user viewing a newly searched city's weather,
**I want** to save it to my favorites (or remove it),
**So that** I don't have to search for it again.

*   **Interaction & Steps:**
    1.  While viewing a searched city's dashboard, the user taps a highlighted "Star" or "Add/Heart" icon in the app bar.
    2.  Alternatively, in the "Saved Locations List", the user swipes left on a city row and taps "Delete".
*   **Outcome:** The city data is written to or deleted from the device's local storage (`get_storage`).
*   **Change in App's View:** 
    *   *Removing:* The row in the Saved Locations List visually slides away and disappears.

---

## Epic 4: Settings & App Launch Experience

### User Story 4.1: Seamless Native App Launch
**As a** user tapping the app icon,
**I want** to see a branded loading screen instantly,
**So that** the app feels native and I don't see a jarring blank white or black screen while it loads.

*   **Interaction & Steps:**
    1.  User taps the AeroSense icon on their home screen.
*   **Outcome:** The OS immediately displays the native splash screen before the Flutter engine starts.
*   **Change in App's View:** A screen matching the brand's background color (dependent on system light/dark mode) with the central logo appears instantly, holding until the Onboarding or Dashboard UI is ready to render.

### User Story 4.2: Toggling Temperature Units
**As a** user with a preference for Celsius or Fahrenheit,
**I want** to globally change the temperature unit used in the app,
**So that** the data is meaningful to me without mental math.

*   **Interaction & Steps:**
    1.  User taps the "Settings" icon (likely located in the app bar or Locations hub).
    2.  User taps a toggle or segmented control switching between "°C" and "°F".
*   **Outcome:** The preference is saved to local storage immediately.
*   **Change in App's View:** The UI instantly recalculates and re-renders every visible temperature on the dashboard, 24-hour forecast, and 7-day outlook without requiring a new API call or app restart.

---

## Technical Tasks Summary (For Developer/GetX Setup)
*(Derived directly from the User Stories above)*

*   **Task 1 (Setup):** Initialize Flutter project, configure native splash screens/icons, install GetX, Dio, Geolocator, Google Fonts, and GetStorage.
*   **Task 2 (Data Layer):** Create Open-Meteo API Provider. Implement Weather fetching and Geocoding search methods.
*   **Task 3 (Controllers):** 
    *   Create `WeatherController` (obs variables for current, hourly, daily, loading states).
    *   Create `LocationController` (handle GPS permission logic, manage saved cities `RxList`).
    *   Create `SettingsController` (manage C/F unit preference from local storage).
*   **Task 4 (UI - Onboarding):** Build the location permission handling flow and the "Empty Search" fallback UI.
*   **Task 5 (UI - Dashboard):** Construct main view, Typography, Insights logic, and `RefreshIndicator` for pull-to-refresh.
*   **Task 6 (UI - Hourly Forecast):** Build the horizontal scrollable timeline.
*   **Task 7 (UI - Daily Forecast):** Build the vertical 7-day list.
*   **Task 8 (UI - Search):** Build the Geocoding search UI with debounce logic.
*   **Task 9 (UI - Locations Management):** Build the Saved Locations Hub with swipe-to-delete functionality and local storage persistence.
*   **Task 10 (UI - Settings):** Build the Settings view to toggle temperature units and bind to `SettingsController`.
