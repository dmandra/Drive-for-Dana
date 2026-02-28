//
//  HardcodedCruiseNightsView.swift
//  LI_Cars_and_CruseNights
//
//  Created by Donald Mandra on 2/22/26.
//

import SwiftUI

// MARK: - Cruise Night Model
struct CruiseNight: Identifiable, Equatable {
    let id = UUID()
    let rowOrder: Int  // Track original spreadsheet order
    let clubName: String
    let name: String
    let location: String
    let time: String
    let dates: String
    let notes: String
}

// MARK: - Cruise Nights View
struct HardcodedCruiseNightsView: View {
    @Binding var dayOfWeekIndex: Int
    @State private var cruiseNights: [CruiseNight] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
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
        
        // Spreadsheet ID from your URL
        let spreadsheetId = "1zSDlFOtKubbo3OCFIz2c-2NWyj49k6CWvHBmB3GQfm0"
        
        // Map day of week index to sheet gid (tab identifier)
        // You'll need to get the gid for each tab from the URL when you open each day's tab
        let sheetGids: [Int: String] = [
            0: "1793929430",  // Sunday - Add gid here
            1: "0",  // Monday - Add gid here
            2: "1908585593",  // Tuesday - Add gid here
            3: "1745799873",  // Wednesday - Add gid here
            4: "837886919",  // Thursday - Add gid here
            5: "2033559366",  // Friday - Add gid here
            6: "354667709"   // Saturday - Add gid here
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
            
            cruiseNights = parseCSV(csvString)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                // Club name at the top (if provided)
                if !cruiseNight.clubName.isEmpty {
                    Text(cruiseNight.clubName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                
                // Event name
                if !cruiseNight.name.isEmpty {
                    Text(cruiseNight.name)
                        .font(.headline)
                }
            }
            
            // Location with map link
            if !cruiseNight.location.isEmpty {
                Button(action: {
                    openInMaps()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.red)
                        Text(cruiseNight.location)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
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
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
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
}

// MARK: - Previews
#Preview("Cruise Nights View") {
    struct PreviewWrapper: View {
        @State private var dayIndex = Calendar.current.component(.weekday, from: Date()) - 1
        
        var body: some View {
            HardcodedCruiseNightsView(dayOfWeekIndex: $dayIndex)
        }
    }
    
    return PreviewWrapper()
}
#Preview("Full App - ContentView") {
    ContentView()
}

