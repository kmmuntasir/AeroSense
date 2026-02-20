# AeroSense API Documentation
**Slogan:** "Making sense of the sky"

This document outlines the specific endpoints from the Open-Meteo API that are required for the AeroSense MVP.

---

## 1. Weather Forecast API

**Description:** Retrieves current weather, hourly forecast (up to 24 hours), and daily forecast (up to 7 days) for a specific location.

*   **API Path:** `https://api.open-meteo.com/v1/forecast`
*   **Method:** `GET`

### Request Parameters (Query String)

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `latitude` | `float` | Yes | Latitude of the location (e.g., `52.52`) |
| `longitude` | `float` | Yes | Longitude of the location (e.g., `13.41`) |
| `current` | `string` | No | Comma-separated list of variables for current weather (e.g., `temperature_2m,apparent_temperature,weather_code`) |
| `hourly` | `string` | No | Comma-separated list of hourly variables (e.g., `temperature_2m,precipitation_probability,weather_code`) |
| `daily` | `string` | No | Comma-separated list of daily variables (e.g., `weather_code,temperature_2m_max,temperature_2m_min`) |
| `temperature_unit` | `string` | No | `celsius` or `fahrenheit` (default: `celsius`) |
| `timezone` | `string` | No | Timezone for timestamps (e.g., `auto` to automatically resolve the local timezone) |

*Note: There is no Request Body since this is a GET request.*

### Data Models & Types

**WeatherResponse Object:**
*   `latitude` (`float`): The requested latitude.
*   `longitude` (`float`): The requested longitude.
*   `timezone` (`string`): The resolved timezone.
*   `current` (`object`): Contains current weather data.
    *   `time` (`string`): ISO8601 timestamp.
    *   `temperature_2m` (`float`): Current temperature.
    *   `apparent_temperature` (`float`): "Feels like" temperature.
    *   `weather_code` (`integer`): WMO weather condition code.
*   `hourly` (`object`): Contains arrays of hourly forecast data.
    *   `time` (`array[string]`): List of ISO8601 timestamps.
    *   `temperature_2m` (`array[float]`): List of temperatures.
    *   `precipitation_probability` (`array[integer]`): List of precipitation probabilities (0-100%).
    *   `weather_code` (`array[integer]`): List of WMO codes.
*   `daily` (`object`): Contains arrays of daily forecast data.
    *   `time` (`array[string]`): List of date strings (YYYY-MM-DD).
    *   `weather_code` (`array[integer]`): List of WMO codes.
    *   `temperature_2m_max` (`array[float]`): Daily maximum temperatures.
    *   `temperature_2m_min` (`array[float]`): Daily minimum temperatures.

### Success Response
**Status:** `200 OK`
```json
{
  "latitude": 52.52,
  "longitude": 13.41,
  "timezone": "Europe/Berlin",
  "current": {
    "time": "2024-05-15T10:00",
    "temperature_2m": 15.5,
    "apparent_temperature": 14.2,
    "weather_code": 3
  },
  "hourly": {
    "time": ["2024-05-15T00:00", "2024-05-15T01:00", "..."],
    "temperature_2m": [12.0, 11.5, "..."],
    "precipitation_probability": [10, 5, "..."],
    "weather_code": [2, 3, "..."]
  },
  "daily": {
    "time": ["2024-05-15", "2024-05-16", "..."],
    "weather_code": [3, 61, "..."],
    "temperature_2m_max": [16.5, 14.0, "..."],
    "temperature_2m_min": [9.0, 8.5, "..."]
  }
}
```

### Failed Response
**Status:** `400 Bad Request`
```json
{
  "error": true,
  "reason": "Cannot initialize WeatherVariable from invalid String value tempeture_2m for key hourly"
}
```

---

## 2. Geocoding API (Search)

**Description:** Searches for cities globally by name or postal code yielding location coordinates.

*   **API Path:** `https://geocoding-api.open-meteo.com/v1/search`
*   **Method:** `GET`

### Request Parameters (Query String)

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | `string` | Yes | The city name or postal code to search for (e.g., `London`) |
| `count` | `integer` | No | Limiting the max number of results (default is `10`) |
| `language` | `string` | No | Two-letter language code for local names (e.g., `en`) |
| `format` | `string` | No | Expected format, typically `json` |

*Note: There is no Request Body since this is a GET request.*

### Data Models & Types

**GeocodingResponse Object:**
*   `results` (`array[CitySearchResult]`): Array of matching locations.

**CitySearchResult Object:**
*   `id` (`integer`): Unique location ID.
*   `name` (`string`): City name.
*   `latitude` (`float`): Geographical latitude.
*   `longitude` (`float`): Geographical longitude.
*   `country` (`string`): Country name.
*   `admin1` (`string`): Primary administrative area/state/region.
*   `timezone` (`string`): Timezone of the location.

### Success Response
**Status:** `200 OK`
```json
{
  "results": [
    {
      "id": 2643743,
      "name": "London",
      "latitude": 51.50853,
      "longitude": -0.12574,
      "country": "United Kingdom",
      "admin1": "England",
      "timezone": "Europe/London"
    }
  ]
}
```

### Failed Response
**Status:** `400 Bad Request`
```json
{
  "error": true,
  "reason": "Parameter count must be between 1 and 100."
}
```
