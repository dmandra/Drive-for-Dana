# Offline Storage Implementation

## Overview
The app now supports offline viewing of car shows and cruise nights data with automatic synchronization when online.

## How It Works

### 1. **DataManager** (DataManager.swift)
A singleton class that manages all local storage and network monitoring:

- **Network Monitoring**: Uses `NWPathMonitor` to track internet connectivity in real-time
- **Local Storage**: Uses `UserDefaults` to cache JSON-encoded data
- **Automatic Sync**: Checks if cached data is older than 1 hour and refreshes when online
- **Per-Month/Day Caching**: Each month's car shows and each day's cruise nights are cached separately

### 2. **Data Models**
Both `CarShow` and `CruiseNight` are now `Codable`:
- Allows encoding/decoding to JSON for storage
- Added explicit `init` methods to support default UUID generation
- Maintains all existing functionality

### 3. **Loading Strategy**

#### Initial Load:
1. Check for cached data locally
2. If cached data exists, display it immediately
3. If cache is older than 1 hour and online, fetch fresh data in background
4. If no cache and offline, show error message

#### Network Fetch:
1. Attempt to fetch data from Google Sheets
2. If successful, update display and save to cache
3. If failed but cache exists, continue showing cached data with "offline" indicator
4. If failed and no cache, show error message

### 4. **Cache Management**
- Each month (0-11) and day (0-6) has separate cache entries
- Timestamps track when data was last fetched
- Cache refresh interval: 3600 seconds (1 hour) - configurable
- Manual cache clearing available via settings (if implemented)

## Files Modified

### CarShowsView.swift
- Added `@StateObject private var dataManager = DataManager.shared`
- Made `CarShow` conform to `Codable`
- Split `loadCarShows()` into two functions:
  - `loadCarShows()`: Checks cache first, then network
  - `fetchCarShowsFromNetwork()`: Handles network requests and saves to cache

### CruiseNightsView.swift
- Added `@StateObject private var dataManager = DataManager.shared`
- Made `CruiseNight` conform to `Codable`
- Split `loadCruiseNights()` into two functions:
  - `loadCruiseNights()`: Checks cache first, then network
  - `fetchCruiseNightsFromNetwork()`: Handles network requests and saves to cache

### DataManager.swift (New)
- Network monitoring
- Save/load car shows with month-specific keys
- Save/load cruise nights with day-specific keys
- Timestamp management
- Cache clearing functionality
- Configurable refresh intervals

### SettingsView.swift (New - Optional)
- Displays network status
- Allows manual cache clearing
- Shows app information
- Can be added to menu if desired

## Benefits

✅ **Offline Access**: Users can view previously loaded data without internet
✅ **Faster Loading**: Cached data displays instantly
✅ **Smart Sync**: Only refreshes when data is stale (>1 hour old)
✅ **Background Updates**: Fresh data loads in background without blocking UI
✅ **Resilient**: Falls back to cache if network request fails
✅ **User Control**: Optional settings view for cache management

## Usage

No changes needed to ContentView or user interaction - it all works automatically!

The app will:
1. Load cached data immediately when available
2. Show loading indicator only when fetching for the first time
3. Refresh data in background when cache is stale
4. Continue working offline with cached data
5. Show "Using cached data (offline)" message when network fails but cache exists

## Storage Details

### UserDefaults Keys:
- Car Shows: `carShows_0` through `carShows_11` (one per month)
- Cruise Nights: `cruiseNights_0` through `cruiseNights_6` (one per day)
- Timestamps: `{key}_timestamp` for each cache entry

### Storage Size:
- Car shows: ~1-5KB per month
- Cruise nights: ~1-3KB per day
- Total: ~50-100KB for full cache (very small)

## Future Enhancements

Potential improvements:
- Add Settings option to main menu
- Show cache age in UI
- Allow configurable refresh interval
- Add force refresh button
- Display storage usage
- Implement background fetch for proactive updates
