//
//  CruiseNightsView.swift
//  LI_Cars_and_CruseNights
//
//  Created by Donald Mandra on 2/22/26.
//

import SwiftUI
import Combine
import CoreLocation
import WeatherKit
import CryptoKit

// MARK: - Cruise Night Model
struct CruiseNight: Identifiable, Equatable, Codable {
    let id: UUID
    let rowOrder: Int  // Track original spreadsheet order
    let clubName: String
    let name: String
    let location: String
    let time: String
    let dates: String
    let notes: String
    
    init(id: UUID = UUID(), rowOrder: Int, clubName: String, name: String, location: String, time: String, dates: String, notes: String) {
        // Generate a deterministic UUID based on unique properties
        // This ensures the same cruise night always has the same ID across app launches
        let idString = "\(clubName)|\(name)|\(location)|\(dates)"
        self.id = Self.generateDeterministicUUID(from: idString)
        
        self.rowOrder = rowOrder
        self.clubName = clubName
        self.name = name
        self.location = location
        self.time = time
        self.dates = dates
        self.notes = notes
    }
    
    // Generate a deterministic UUID from a string using SHA256
    private static func generateDeterministicUUID(from string: String) -> UUID {
        // Hash the string to get a deterministic result
        let hash = SHA256.hash(data: Data(string.utf8))
        
        // Take first 16 bytes of the hash to create a UUID
        let hashBytes = Array(hash.prefix(16))
        
        // Format as UUID string (8-4-4-4-12 format)
        let uuidString = String(format: "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
                               hashBytes[0], hashBytes[1], hashBytes[2], hashBytes[3],
                               hashBytes[4], hashBytes[5],
                               hashBytes[6], hashBytes[7],
                               hashBytes[8], hashBytes[9],
                               hashBytes[10], hashBytes[11], hashBytes[12], hashBytes[13], hashBytes[14], hashBytes[15])
        
        return UUID(uuidString: uuidString) ?? UUID()
    }
}

// Type alias for cleaner usage in ContentView
//typealias CruiseNightsView = HardcodedCruiseNightsView

// MARK: - Cruise Nights View
struct CruiseNightsView: View {
    @Binding var dayOfWeekIndex: Int
    @State private var cruiseNights: [CruiseNight] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @ObservedObject private var dataManager = DataManager.shared
    
    let daysOfWeek: [String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var dayOfWeek: String {
        daysOfWeek[dayOfWeekIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView("Loading cruise nights...")
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Unable to load cruise nights")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            await loadCruiseNights()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                Spacer()
            } else if cruiseNights.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "car.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No cruise nights scheduled")
                        .font(.headline)
                    Text("Check back later for updates")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(cruiseNights) { night in
                            CruiseNightCard(cruiseNight: night)
                            
                            Divider()
                        }
                        
                        // Footer below cruise nights
                        Text("Check back regularly for updates. Cruise Night schedules may change.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom)
                }
            }
        }
        .task(id: dayOfWeekIndex) {
            await loadCruiseNights()
        }
    }
    
    private func loadCruiseNights() async {
        isLoading = true
        errorMessage = nil
        
        // Try to load cached data first
        if let cachedNights = dataManager.loadCruiseNights(for: dayOfWeekIndex) {
            cruiseNights = cachedNights
            isLoading = false
            
            // Check if we should refresh in the background
            let timestamp = dataManager.getCruiseNightsTimestamp(for: dayOfWeekIndex)
            if dataManager.isOnline && dataManager.shouldRefreshCache(for: timestamp, maxAge: 86400) {
                // Refresh in background
                await fetchCruiseNightsFromNetwork()
            }
            return
        }
        
        // No cached data, try to fetch from network
        if dataManager.isOnline {
            await fetchCruiseNightsFromNetwork()
        } else {
            errorMessage = "No internet connection and no cached data available"
            isLoading = false
        }
    }
    
    private func fetchCruiseNightsFromNetwork() async {
        // Spreadsheet ID from your URL
        let spreadsheetId = "1zSDlFOtKubbo3OCFIz2c-2NWyj49k6CWvHBmB3GQfm0"
        
        // Map day of week index to sheet gid (tab identifier)
        let sheetGids: [Int: String] = [
            0: "1793929430",  // Sunday
            1: "0",  // Monday
            2: "1908585593",  // Tuesday
            3: "1745799873",  // Wednesday
            4: "837886919",  // Thursday
            5: "2033559366",  // Friday
            6: "354667709"   // Saturday
        ]
        
        // Get the sheet gid for the current day
        guard let gid = sheetGids[dayOfWeekIndex], !gid.isEmpty else {
            // No sheet configured for this day
            cruiseNights = []
            isLoading = false
            return
        }
        
        let csvURL = "https://docs.google.com/spreadsheets/d/\(spreadsheetId)/export?format=csv&gid=\(gid)"
        
        guard let url = URL(string: csvURL) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let csvString = String(data: data, encoding: .utf8) else {
                errorMessage = "Unable to parse data"
                isLoading = false
                return
            }
            
            let newNights = parseCSV(csvString)
            cruiseNights = newNights
            
            // Save to cache
            dataManager.saveCruiseNights(newNights, for: dayOfWeekIndex)
            
            isLoading = false
        } catch {
            // If we have cached data, keep using it
            if let cachedNights = dataManager.loadCruiseNights(for: dayOfWeekIndex) {
                cruiseNights = cachedNights
                errorMessage = "Using cached data (offline)"
            } else {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func parseCSV(_ csv: String) -> [CruiseNight] {
        let rows = csv.components(separatedBy: .newlines)
        var nights: [CruiseNight] = []
        var rowOrder = 0  // Track order
        
        // Skip header row (index 0) and parse data rows
        for (index, row) in rows.enumerated() {
            guard index > 0, !row.isEmpty else { continue }
            
            // Parse CSV row (handle quoted fields that may contain commas)
            let columns = parseCSVRow(row)
            
            // Expecting 6 columns: Club Name, Name, Location, Time, Dates, Notes
            guard columns.count >= 6 else { continue }
            
            let clubName = columns[0].trimmingCharacters(in: .whitespaces)
            let name = columns[1].trimmingCharacters(in: .whitespaces)
            let location = columns[2].trimmingCharacters(in: .whitespaces)
            let time = columns[3].trimmingCharacters(in: .whitespaces)
            let dates = columns[4].trimmingCharacters(in: .whitespaces)
            let notes = columns[5].trimmingCharacters(in: .whitespaces)
            
            // Skip rows where essential fields (name or location) are empty
            guard !name.isEmpty || !location.isEmpty else { continue }
            
            let night = CruiseNight(
                rowOrder: rowOrder,
                clubName: clubName,
                name: name,
                location: location,
                time: time,
                dates: dates,
                notes: notes
            )
            
            nights.append(night)
            rowOrder += 1  // Increment for next valid row
        }
        
        return nights
    }
    
    private func parseCSVRow(_ row: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false
        
        for char in row {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                columns.append(currentColumn)
                currentColumn = ""
            } else {
                currentColumn.append(char)
            }
        }
        
        // Add the last column
        columns.append(currentColumn)
        
        return columns
    }
}

// MARK: - Cruise Night Card Component
struct CruiseNightCard: View {
    let cruiseNight: CruiseNight
    @State private var weatherItem: IdentifiableLocation?
    @State private var isGeocodingAddress = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            //VStack(alignment: .leading, spacing: 2) {
                
                // Club name at the top (if provided)
                if !cruiseNight.clubName.isEmpty {
                    Text(cruiseNight.clubName)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                
                // Event name
                if !cruiseNight.name.isEmpty {
                    Text(cruiseNight.name)
                        //.font(.headline)
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            //}
            
            // Address with map link
            if !cruiseNight.location.isEmpty {
                Button(action: {
                    openInMaps()
                }) {
                    //HStack(spacing: 4) {
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.red)
                        Text(cruiseNight.location)
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
            
            // Time
            if !cruiseNight.time.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(cruiseNight.time)
                        .font(.subheadline)
                    
                    Spacer()
                }
            }
            
            // Dates
            if !cruiseNight.dates.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(cruiseNight.dates)
                        .font(.subheadline)
                    
                    Spacer()
                }
            }
            
            // Notes
            if !cruiseNight.notes.isEmpty {
                Text(cruiseNight.notes)
                    .font(.caption)
                    .lineLimit(3)
            }
            
            // Check Weather Button (only show if location exists)
            if !cruiseNight.location.isEmpty {
                Button(action: {
                    openInWeather()
                }) {
                    HStack {
                        if isGeocodingAddress {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Image(systemName: "cloud.sun")
                        }
                        Text("Check Weather")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                .disabled(isGeocodingAddress)
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .sheet(item: $weatherItem) { item in
            WeatherView(location: item.location, address: item.address)
        }
    }
    
    private func openInMaps() {
        let encodedLocation = cruiseNight.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "maps://?q=\(encodedLocation)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                if let webURL = URL(string: "https://maps.apple.com/?q=\(encodedLocation)") {
                    UIApplication.shared.open(webURL)
                }
            }
        }
    }
    
    private func openInWeather() {
        // Show loading indicator
        isGeocodingAddress = true
        
        // Geocode the address to get coordinates for WeatherKit
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(cruiseNight.location) { placemarks, error in
            DispatchQueue.main.async {
                // Hide loading indicator
                self.isGeocodingAddress = false
                
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    return
                }
                
                guard let placemark = placemarks?.first,
                      let location = placemark.location else {
                    print("No location found for address")
                    return
                }
                
                // Create identifiable location item - this will trigger the sheet to present
                self.weatherItem = IdentifiableLocation(location: location, address: self.cruiseNight.location)
            }
        }
    }
}

// MARK: - Previews
#Preview("Cruise Nights View") {
    struct PreviewWrapper: View {
        @State private var dayIndex = Calendar.current.component(.weekday, from: Date()) - 1
        
        var body: some View {
            CruiseNightsView(dayOfWeekIndex: $dayIndex)
        }
    }
    
    return PreviewWrapper()
}
#Preview("Full App - ContentView") {
    ContentView()
}

