//
//  EventsView.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 2/25/26.
//

import SwiftUI
import Combine

// MARK: - Event Model
struct Event: Identifiable, Equatable {
    let id = UUID()
    let rowOrder: Int  // Track original spreadsheet order
    let name: String
    let date: String
    let time: String
    let location: String
    let notes: String
    let phone: String
    let email: String
    let website: String
    
}

// MARK: - Events View
struct EventsView: View {
    @State private var events: [Event] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView("Loading events...")
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Unable to load events")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            await loadEvents()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                Spacer()
            } else if events.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No events scheduled")
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
                        // Header text
                        VStack(spacing: 8) {
                            Text("UPCOMING EVENTS")
                                .font(.title2)
                                .fontWeight(.bold)
                            //Divider()
                            
                            //Text("Join us at our upcoming Drive for Dana events! All proceeds support medically fragile //children across Long Island.")
                                //.font(.subheadline)
                                //.foregroundStyle(.secondary)
                                //.multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Events list
                        ForEach(events) { event in
                            EventCard(event: event)
                            
                            Divider()
                        }
                        
                        // Footer text
                        VStack(spacing: 8) {
                            Text("📅 MORE EVENTS COMING SOON")
                                .font(.headline)
                            
                            Text("Stay tuned for additional fundraising events throughout the year. Follow us on social media for the latest updates!")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .task {
            await loadEvents()
        }
    }
    
    private func loadEvents() async {
        isLoading = true
        errorMessage = nil
        
        // Spreadsheet ID from your URL
        let spreadsheetId = "19JcRZApNCTLAlu3rz-6QEbI8UqUO4uR4HnHhhhpVjso"
        
        // Since there's only one sheet, we can use gid=0 or get the specific gid from the URL
        let gid = "0"  // Update this if needed by checking the URL when you open the sheet
        
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
            
            events = parseCSV(csvString)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    private func parseCSV(_ csv: String) -> [Event] {
        let rows = csv.components(separatedBy: .newlines)
        var parsedEvents: [Event] = []
        var rowOrder = 0  // Track order
        
        // Skip header row (index 0) and parse data rows
        for (index, row) in rows.enumerated() {
            guard index > 0, !row.isEmpty else { continue }
            
            // Parse CSV row (handle quoted fields that may contain commas)
            let columns = parseCSVRow(row)
            
            // Expecting 5 columns: Name, Date, Time, Location, Notes
            guard columns.count >= 8 else { continue }
            
            let name = columns[0].trimmingCharacters(in: .whitespaces)
            let date = columns[1].trimmingCharacters(in: .whitespaces)
            let time = columns[2].trimmingCharacters(in: .whitespaces)
            let location = columns[3].trimmingCharacters(in: .whitespaces)
            let notes = columns[4].trimmingCharacters(in: .whitespaces)
            let phone = columns[5].trimmingCharacters(in: .whitespaces)
            let email = columns[6].trimmingCharacters(in: .whitespaces)
            let website = columns[7].trimmingCharacters(in: .whitespaces)
            
            // Skip rows where essential fields (name) are empty
            guard !name.isEmpty else { continue }
            
            let event = Event(
                rowOrder: rowOrder,
                name: name,
                date: date,
                time: time,
                location: location,
                notes: notes,
                phone: phone,
                email: email,
                website: website
                
            )
            
            parsedEvents.append(event)
            rowOrder += 1  // Increment for next valid row
        }
        
        return parsedEvents
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

// MARK: - Event Card Component
struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Event Name (with emoji if present)
            if !event.name.isEmpty {
                Text(event.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Date
            if !event.date.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.subheadline)
                    Text("\(event.date)")
                    //Text("Date: \(event.date)")
                        .font(.subheadline)
                        //.fontWeight(.bold)
                }
            }
            
            // Time
            if !event.time.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.subheadline)
                    Text("\(event.time)")
                        .font(.subheadline)
                        //.fontWeight(.bold)
                }
            }
            
            // Location (with map link)
            if !event.location.isEmpty {
                Button(action: {
                    openInMaps()
                }) {
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.red)
                        Text("\(event.location)")
                            .font(.subheadline)
                            //.fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                }
                .buttonStyle(.plain)
            }
            
            // Notes/Details
            if !event.notes.isEmpty {
                Text(event.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Phone (tappable to call)
            if !event.phone.isEmpty {
                Button(action: {
                    callPhone()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.green)
                        Text(event.phone)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                }
                .buttonStyle(.plain)
            }
            
            // Email (tappable to compose)
            if !event.email.isEmpty {
                Button(action: {
                    sendEmail()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.blue)
                        Text(event.email)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                }
                .buttonStyle(.plain)
            }
            
            // Website (tappable to open in Safari)
            if !event.website.isEmpty {
                Button(action: {
                    openWebsite()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .foregroundStyle(.blue)
                        Text(event.website)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                }
                .buttonStyle(.plain)
            }
            
        }

        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func openInMaps() {
        let encodedLocation = event.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
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
    
    private func callPhone() {
        // Remove any formatting characters to create a clean phone number
        let cleanedPhone = event.phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if let url = URL(string: "tel:\(cleanedPhone)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func sendEmail() {
        // Extract email if it contains extra text
        let emailAddress = event.email.trimmingCharacters(in: .whitespaces)
        let encodedEmail = emailAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? emailAddress
        
        if let url = URL(string: "mailto:\(encodedEmail)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func openWebsite() {
        var urlString = event.website.trimmingCharacters(in: .whitespaces)
        
        // Add https:// if no protocol is specified
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Previews
#Preview("Events View") {
    EventsView()
}

#Preview("Full App - ContentView") {
    ContentView()
}
