# Product Requirements Document (PRD)

**Product Name:** AeroSense (MVP) - "Making sense of the sky"
**Document Owner:** Product Manager / Founder
**Target Audience:** General smartphone users looking for quick, actionable weather information.
**Data Source:** Open-Meteo API (No API keys required, free tier).

---

## 1. Product Vision & Objective

To build a lightning-fast, highly intuitive AeroSense app that doesn't just show numbers, but provides meaningful, actionable insights for the user's day. The MVP will focus strictly on the most crucial weather data points that impact daily decision-making (e.g., "Do I need an umbrella?", "Should I wear a jacket?").

---

## 2. Core Philosophy for the Designer

*   **Information Hierarchy is Key:** Users should grasp the current situation in 1-2 seconds.
*   **Actionable over Analytical:** Users prefer to know "Rain starting in 20 mins" rather than just looking at a 70% humidity stat.
*   **No Visual Constraints:** The UI/UX designer has full autonomy over the visual identity (colors, typography, iconography, animations, layout). This document only dictates what elements must exist, not how they look.

---

## 3. Core MVP Features & Requirements

### Feature 1: The "Glanceable" Current Weather Dashboard
*   **Goal:** Provide the most critical current weather data instantly upon opening the app.
*   **Required Data Elements to Display:**
    *   Current City/Location Name.
    *   Current Temperature (Large, prominent).
    *   Weather Condition (Text description like "Partly Cloudy", "Heavy Rain", plus space for a corresponding icon/graphic).
    *   "Feels Like" Temperature (Apparent temperature).
    *   Today's High and Low Temperatures.
    *   **Meaningful Insight (Crucial MVP Feature):** A short, dynamic text string providing immediate context.
        *   *Examples:* "Rain expected around 3:00 PM.", "High UV index today, wear sunscreen.", "Colder than yesterday."
        *   The designer must allocate UI space for this dynamic 1-2 sentence text block.
    *   **Pull-to-Refresh:** The dashboard must support a manual pull-down gesture to instantly refresh all weather data for the current location.

### Feature 2: 24-Hour Short-Term Forecast
*   **Goal:** Help the user plan their immediate day/evening.
*   **Required Data Elements to Display:**
    *   A scrollable/swipeable timeline (typically horizontal, but designer can decide).
    *   **Data points per hour:**
        *   Time (e.g., 1 PM, 2 PM).
        *   Temperature.
        *   Weather Condition Icon.
        *   Precipitation Chance (Percentage) only if it is > 0%.

### Feature 3: 7-Day Outlook
*   **Goal:** Help the user plan for the upcoming week.
*   **Required Data Elements to Display:**
    *   A list or grid showing the next 7 days.
    *   **Data points per day:**
        *   Day of the week (e.g., Mon, Tue).
        *   Weather Condition Icon.
        *   High and Low Temperatures.

### Feature 4: Location Search & Favorites Management
*   **Goal:** Allow users to check weather in other cities and save them for quick access.
*   **Required Interactions & Elements:**
    *   **Search Bar/Action:** An entry point to search for a new city.
    *   **Search Results List:** Displaying City Name, State/Country.
    *   **Saved Locations Hub:** A view (could be a drawer, a separate tab, or a swipeable carousel) showing saved cities.
    *   **Data in Saved Locations List:** Each saved city item must show: City Name, Current Temp, Current Condition Icon, and Local Time.
    *   **Action:** Ability to add/remove a city from the saved list.

### Feature 5: User Settings
*   **Goal:** Allow users to customize their weather experience.
*   **Required Interactions & Elements:**
    *   **Unit Toggle:** A clear switch or toggle between Celsius (°C) and Fahrenheit (°F). This preference must apply app-wide.
    *   **Theme Toggle (Optional for MVP, but recommended):** A toggle between System Default, Light Mode, and Dark Mode.

### Feature 6: Native App Launch Experience
*   **Goal:** Ensure AeroSense feels like a premium, native installation from the moment it is tapped.
*   **Required Elements:**
    *   **App Icon:** A distinct, branded launcher icon for iOS and Android.
    *   **Native Splash Screen:** A branded loading screen that appears instantly upon launch while the Flutter engine initializes, matching the brand colors to prevent white/black screen flashing.

---

## 4. User Flow Definitions

### First Launch (Onboarding):
1.  App asks for Location Permission.
2.  **If granted:** Automatically loads the Dashboard (Feature 1) for their GPS coordinates.
3.  **If denied:** Prompts the user to manually search for a city using the Search feature (Feature 4).

### Daily Usage:
*   User opens app -> Lands directly on Dashboard for their primary/current location.
*   User scrolls down (or swipes) -> Sees 24-hour forecast, then 7-day outlook.

### Managing Locations & Settings:
1.  User taps "Locations" icon -> Opens Saved Locations list.
2.  User taps "Search" -> Types city -> Selects from list -> Views that city's weather -> Taps "Add to favorites" (optional).
3.  User taps "Settings" (usually gear icon) -> Toggles temperature unit -> Interface instantly updates to reflect new unit.

---

## 5. API Data Mapping (For UI Context)

To help the designer understand the exact data formats coming from Open-Meteo that the UI needs to accommodate:

*   **Temperatures:** Whole numbers (e.g., 72° or 22°). The user can toggle between F/C in the new Settings view. The UI must accommodate up to 3 characters plus the degree symbol.
*   **Precipitation:** Percentages (e.g., 45%).
*   **Weather Codes:** Open-Meteo uses WMO codes (0-99). The dev will map these to specific conditions (Clear, Cloudy, Fog, Rain, Snow, Thunderstorm). The designer needs to prepare an icon set covering these 6-8 basic categories.

---

## 6. Out of Scope for MVP (Do Not Design)

To keep the designer focused, please omit the following from the initial designs:

*   Interactive Radar / Weather Maps.
*   Severe Weather Push Notifications / Government Alerts.
*   Detailed environmental data (Air Quality Index, Pollen counts, Moon phases, Wind speed/direction grids).
*   User Accounts / Login screens.
*   Social sharing features.