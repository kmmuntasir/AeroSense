# AeroSense MVP: UI & UX Design Descriptions
**Slogan:** "Making sense of the sky"

**Document Purpose:** This document serves as the visual and interaction blueprint for the AeroSense MVP, derived directly from the PRD, Brand Guidelines, User Stories, and Task Descriptions. It details the precise layout, typography hierarchy, visual states, and micro-interactions for every user journey.

**Design Philosophy & Vibe:**
*   **Aesthetic:** Clean, modern, trustworthy, and actionable.
*   **Typography:** High legibility is paramount (Inter, SF Pro, or Roboto). Large, bold numeric data paired with medium-weight actionable text. Tabular figures are mandatory for timelines.
*   **Colors:** Deep reliance on whitespace (Off-white `#F8F9FA` for Light mode, Deep Slate `#121212` for Dark mode). "Sky Indigo" `#4A90E2` serves as the primary action/accent color. Semantic colors signify weather states (e.g., Ice Blue for cold, Warm Coral for hot).
*   **Shapes:** Friendly, approachable 12px-16px border radii on all containers and cards. Solid, distinct iconography.

---

## 1. Onboarding & First Launch (Journey 1)

### 1.1 Native Splash Screen (The First 0.5 Seconds)
*   **Visuals:** A solid, uninterrupted background matching the system theme (Off-White or Deep Slate). Dead-center is the AeroSense app icon (Sky Indigo).
*   **Typography:** No typography is present to avoid clutter and prevent flashing before the Flutter engine renders fonts.
*   **Interaction:** Holds statically until the OS hands over to the app's first frame.

### 1.2 Location Permission Request
*   **Visuals:** The app renders its background color. A native OS-level dialog box (iOS/Android standard) overlays the screen requesting location access.
*   **Interaction:** 
    *   **User taps "Allow":** A subtle, centered Sky Indigo loading spinner fades in for <1s while the API fetches data. The screen then smoothly cross-fades directly into the populated **Dashboard View**.
    *   **User taps "Deny":** The screen slides up (bottom-to-top transition) into the **Initial Search/Empty State View**.

### 1.3 Initial Search / Empty State View (Location Denied)
*   **Layout:** Centered content with generous top padding to feel breathable.
*   **Visuals:**
    *   *Optional:* A polished, solid-color line icon (magnifying glass over a globe) sits above the text.
    *   **Headline:** "Let's find your weather" (H2, Bold, Dark Text, centered).
    *   **Subtext:** "Search for a city to check the current forecast." (Body text, Regular weight, Medium Gray, centered below headline).
*   **The Search Bar:**
    *   **Position:** Centered, directly below the subtext.
    *   **Style:** Large hit area (56px height). Background slightly darker than the app canvas (e.g., `#EDEDED` light / `#2A2D32` dark). Fully rounded (pill shape) or 16px border radius.
    *   **Elements:** A left-aligned magnifying glass icon (Sky Indigo). Placeholder text "Search city..." (Light Gray).
*   **Interaction (The "Search" Action):**
    *   Tapping the search bar instantly animates it up to the Top Safe Area, snapping it into a persistent header position. The keyboard slides up simultaneously.
    *   As the user types, a dropdown list (`ListView`) populates immediately below the search bar.
    *   **List Items:** Distinct rows with 16px vertical padding. The matching City Name is heavily bolded; the State/Country follows in smaller, regular gray text.
    *   **Selection:** Tapping a result instantly dismisses the keyboard and pushes the user directly to the **Dashboard View** populated with that city's data.

---

## 2. The Core Weather Dashboard (Journey 2: Daily Check)

This view is the heart of the app. It must communicate the entire current situation within a 1-2 second glance without scrolling.

### 2.1 Top Navigation Bar (App Bar area)
*   **Layout:** Clean and minimalist, almost invisible against the background.
*   **Left Anchor:** Menu / "Hamburger" icon (navigates to Locations Hub).
*   **Center Anchor:** Either completely empty (preferred for modern cleanliness) or a very subtle, small AeroSense wordmark.
*   **Right Anchor 1:** A "Star" or "Heart" icon. 
    *   *State:* Outlined/Gray if the currently viewed city is *not* saved. Solid Sky Indigo if it *is* saved in favorites.
*   **Right Anchor 2 (Far Right):** A "Gear" icon (navigates to Settings).

### 2.2 Section 1: The "Glanceable" Dashboard (Top half of scroll view)
Focuses entirely on the immediate present.
*   **Location Marker:** Top-centered. Huge typography (`H1` equivalent, Bold, e.g., 32px-40px). Deep contrast color (nearly black/white).
*   **The Centerpiece (Temp & Visual):**
    *   **Temperature:** Positioned dead-center below the location. Massive, dominant typography (e.g., 96dp size, heavy bold, potentially using a Condensed font variant to save horizontal space).
    *   **Condition Icon:** Positioned immediately adjacent to (or directly above) the temperature. A large, premium solid-color SVG representing the WMO code.
    *   **Condition Text:** Directly below the temperature. e.g., "Partly Cloudy" (18px, Medium weight, dark color).
*   **The Secondary Data Row:**
    *   A horizontal flex row below the condition text.
    *   Displays three data points: "Feels Like: 75°", "High: 80°", "Low: 65°".
    *   **Style:** Light weight typography, subdued gray color so it does not visually compete with the massive current temperature.
*   **The "Meaningful Insights" Card (Crucial Element):**
    *   Positioned right below the secondary data.
    *   **Visuals:** A distinct UI card (12px border radius). The background color of this card is tinted semantically based on the insight (e.g., a very faint crimson tint for a UV warning, or faint teal for rain).
    *   **Typography:** The insight string (e.g., "Rain expected around 3:00 PM. Grab an umbrella!") is displayed in medium-weight, highly readable text. The tone is conversational and actionable.
*   **Interaction (Pull-to-Refresh):** 
    *   Pulling down on the scroll view stretches a native loading spinner from the top edge. It spins rapidly while fetching, then snaps back up when new data renders.

### 2.3 Section 2: 24-Hour Short-Term Forecast (Middle section)
Focuses on the immediate timeline.
*   **Header:** "Today" or "Next 24 Hours" aligned to the left edge above the list. (Bold, 18px).
*   **Layout:** A horizontal, seamlessly scrollable row extending off the right edge of the screen to indicate scrolling capability.
*   **Hourly Item Cards (Width: ~70px):**
    *   Stacked vertically inside the card:
        1.  **Time:** "Now", "1 PM", "2 PM" (Small, Medium weight).
        2.  **Icon:** Medium-sized weather icon.
        3.  **Temperature:** "72°" (Bold, tabular numbers).
        4.  **Precipitation (Conditional):** "45%" (Small, Sky Indigo or light blue color). *Only* visible if the chance is > 0% to reduce visual noise.
*   **Interaction:** Smooth horizontal swipe.

### 2.4 Section 3: 7-Day Outlook (Bottom section)
Focuses on the long-term trend.
*   **Header:** "7-Day Forecast" aligned to the left edge. (Bold, 18px).
*   **Layout:** A simple vertical list pushing down below the fold.
*   **Daily Item Rows (Full Width):**
    *   **Left Anchor:** Day Name ("Mon", "Tue"). Fixed-width text box so all days align perfectly vertically down the screen.
    *   **Center Anchor:** Small weather condition icon.
    *   **Right Anchor:** High and Low temperatures.
        *   Layout: Low Temp (subdued gray) `<space>` Visual range bar (optional polish) `<space>` High Temp (dark bold).
*   **Typography:** Tabular figures are absolutely required here so the temperatures form neat vertical columns regardless of digit width (e.g., "9°" vs "11°").

---

## 3. Locations Management & Search (Journey 3)

### 3.1 Saved Locations Hub
*   **Access:** Tapping the top-left menu icon on the dashboard.
*   **Transition:** The view slides up from the bottom (modal style) or slides in from the left (drawer style).
*   **Header:** Title "Saved Locations". Close/X icon on the top right to dismiss.
*   **Top Action:** A persistent, wide "Search for a new city..." simulated text field (or elevated FAB) sits at the very top. Tapping it pushes to the true Search Screen (detailed in 1.3).
*   **The List View (Saved Cities):**
    *   Vertical list of visually elevated cards (16px border radius, slight drop shadow or distinct background color to pop off the canvas).
    *   **Card Anatomy:**
        *   **Left Side:** City Name (Large, Bold), stacked above Local Time (Small, light gray).
        *   **Right Side:** WMO Condition Icon alongside a huge Current Temperature.
*   **Interaction (Swipe-to-Delete):**
    *   User places finger on a city card and swipes left.
    *   A bright red background is revealed underneath with a white "Trash" icon.
    *   Swiping past the threshold (or tapping the revealed trash icon) animates the card shrinking vertically (size transition) and fading out, removing it from the list.

---

## 4. Settings & Preferences (Journey 4)

### 4.1 Settings View
*   **Access:** Tapping the top-right gear icon on the dashboard.
*   **Transition:** Standard right-to-left navigation push.
*   **Header:** Title "Settings". Standard OS back arrow on the left.
*   **Layout:** A crisp, grouped vertical list. Items are separated by subtle 1px light gray dividers.
*   **Interactions:**
    *   **Temperature Unit Toggle:** 
        *   Text: "Temperature Unit".
        *   Control: A highly polished segmented control pill on the right side. Options: "°C" | "°F".
        *   State: The active selection has a Sky Indigo background with white text; the inactive side has a light gray background with dark text. Tapping smoothly animates the pill background sliding over.
    *   **App Theme Toggle (Optional):**
        *   Text: "App Theme".
        *   Control: Segmented control or a clean dropdown. Options: System | Light | Dark.
    *   *Effect:* Changes made here immediately recalculate the UI stack beneath it. When the user taps 'Back', the Dashboard is already fully updated with the new units/colors without requiring a refresh.
