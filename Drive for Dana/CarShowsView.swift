//
//  CarShowsView.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 2/25/26.
//

import SwiftUI
import Combine

// MARK: - Car Show Model
struct CarShow: Identifiable, Equatable, Codable {
    let id: UUID
    let rowOrder: Int  // Track original spreadsheet order
    let date: String
    let club: String
    let name: String
    let time: String
    let description: String
    let location: String
    let address: String
    let carFee: String
    let spectatorFee: String
    let notes: String
    let contact: String
    let email: String
    let website: String
    let rainDate: String
    let vendors: String
    let vendorFee: String
    
    init(id: UUID = UUID(), rowOrder: Int, date: String, club: String, name: String, time: String, description: String, location: String, address: String, carFee: String, spectatorFee: String, notes: String, contact: String, email: String, website: String, rainDate: String, vendors: String, vendorFee: String) {
        self.id = id
        self.rowOrder = rowOrder
        self.date = date
        self.club = club
        self.name = name
        self.time = time
        self.description = description
        self.location = location
        self.address = address
        self.carFee = carFee
        self.spectatorFee = spectatorFee
        self.notes = notes
        self.contact = contact
        self.email = email
        self.website = website
        self.rainDate = rainDate
        self.vendors = vendors
        self.vendorFee = vendorFee
    }
    
    // Parse date string to Date object for comparison
    var parsedDate: Date? {
        let dateFormatter = DateFormatter()
        // Try common date formats
        let formats = [
            "M/d/yyyy",      // 3/15/2026
            "MM/dd/yyyy",    // 03/15/2026
            "M/d/yy",        // 3/15/26
            "MM/dd/yy",      // 03/15/26
            "MMMM d, yyyy",  // March 15, 2026
            "MMM d, yyyy"    // Mar 15, 2026
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: date) {
                return date
            }
        }
        return nil
    }
    
    // Check if this show is today or in the future
    var isUpcoming: Bool {
        guard let showDate = parsedDate else {
            return true // If we can't parse the date, show it anyway
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let showDay = calendar.startOfDay(for: showDate)
        
        return showDay >= today
    }
}

// MARK: - Car Shows View
struct CarShowsView: View {
    @Binding var monthIndex: Int
    @State private var carShows: [CarShow] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @ObservedObject private var dataManager = DataManager.shared
    
    let months: [String] = Calendar.current.monthSymbols
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation {
                        monthIndex = (monthIndex - 1 + months.count) % months.count
                    }
                }) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.bordered)
                
                Text("\(months[monthIndex]) 2026")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())
                
                Button(action: {
                    withAnimation {
                        monthIndex = (monthIndex + 1) % months.count
                    }
                }) {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            
            if isLoading {
                Spacer()
                ProgressView("Loading car shows...")
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Unable to load car shows")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            await loadCarShows()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                Spacer()
            } else if carShows.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No car shows scheduled")
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
                        // Text message above first car show
                        //Text("Upcoming Car Shows for \(months[monthIndex])")
                        //Text("Check Back Often")
                           // .font(.subheadline)
                           // .foregroundStyle(.secondary)
                           // .padding(.vertical, 2)
                            //.frame(maxWidth: .infinity, alignment: .center)
                        Text("Contact Us from the Home Menu for adding your event or for corrections.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 2)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        ForEach(carShows) { show in
                            CarShowCard(carShow: show)
                            
                            Divider()
                        }
                        
                        // Text message below last car show
                        Text("Past shows are filtered out in order to show future shows only. Please verify details directly with the car show organizers.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .padding(.bottom)
                }
            }
        }
        .task(id: monthIndex) {
            await loadCarShows()
        }
    }
    
    private func loadCarShows() async {
        isLoading = true
        errorMessage = nil
        
        // Try to load cached data first
        if let cachedShows = dataManager.loadCarShows(for: monthIndex) {
            carShows = cachedShows
            isLoading = false
            
            // Check if we should refresh in the background
            let timestamp = dataManager.getCarShowsTimestamp(for: monthIndex)
            if dataManager.isOnline && dataManager.shouldRefreshCache(for: timestamp, maxAge: 86400) {
                // Refresh in background
                await fetchCarShowsFromNetwork()
            }
            return
        }
        
        // No cached data, try to fetch from network
        if dataManager.isOnline {
            await fetchCarShowsFromNetwork()
        } else {
            errorMessage = "No internet connection and no cached data available"
            isLoading = false
        }
    }
    
    private func fetchCarShowsFromNetwork() async {
        // Single spreadsheet ID
        let spreadsheetId = "1WBhNXkVSf9VVjVM9Dfw6mG31gVM877kuSM0kioOHjus"
        
        // Map month index to sheet gid (tab identifier)
        // To find the gid: Open each tab and look at the URL, it will show #gid=123456789
        let sheetGids: [Int: String] = [
            0: "1081313977",  // January - add gid here
            1: "1692556642",  // February
            2: "722941395",  // March
            3: "858423076",  // April
            4: "1122570857",  // May
            5: "1881219469",  // June
            6: "186732713",  // July
            7: "1338027119",  // August
            8: "1839427359",  // September
            9: "1155943106",  // October
            10: "1592260621", // November
            11: "342572286"  // December
        ]
        
        // Get the sheet gid for the current month
        guard let gid = sheetGids[monthIndex], !gid.isEmpty else {
            // No sheet configured for this month
            carShows = []
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
            
            let newShows = parseCSV(csvString)
            carShows = newShows
            
            // Save to cache
            dataManager.saveCarShows(newShows, for: monthIndex)
            
            isLoading = false
        } catch {
            // If we have cached data, keep using it
            if let cachedShows = dataManager.loadCarShows(for: monthIndex) {
                carShows = cachedShows
                errorMessage = "Using cached data (offline)"
            } else {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func parseCSV(_ csv: String) -> [CarShow] {
        let rows = csv.components(separatedBy: .newlines)
        var shows: [CarShow] = []
        var rowOrder = 0  // Track order
        
        // Skip header row (index 0) and parse data rows
        for (index, row) in rows.enumerated() {
            guard index > 0, !row.isEmpty else { continue }
            
            // Parse CSV row (handle quoted fields that may contain commas)
            let columns = parseCSVRow(row)
            
            // Expecting 16 columns: Date, Club, Name, Time, Description, Location, Address, Car Fee, Spectator Fee, Notes, Contact, Email, Website, Rain Date, Vendors, Vendor Fee
            guard columns.count >= 16 else { continue }
            
            let date = columns[0].trimmingCharacters(in: .whitespaces)
            let club = columns[1].trimmingCharacters(in: .whitespaces)
            let name = columns[2].trimmingCharacters(in: .whitespaces)
            let time = columns[3].trimmingCharacters(in: .whitespaces)
            let description = columns[4].trimmingCharacters(in: .whitespaces)
            let location = columns[5].trimmingCharacters(in: .whitespaces)
            let address = columns[6].trimmingCharacters(in: .whitespaces)
            let carFee = columns[7].trimmingCharacters(in: .whitespaces)
            let spectatorFee = columns[8].trimmingCharacters(in: .whitespaces)
            let notes = columns[9].trimmingCharacters(in: .whitespaces)
            let contact = columns[10].trimmingCharacters(in: .whitespaces)
            let email = columns[11].trimmingCharacters(in: .whitespaces)
            let website = columns[12].trimmingCharacters(in: .whitespaces)
            let rainDate = columns[13].trimmingCharacters(in: .whitespaces)
            let vendors = columns[14].trimmingCharacters(in: .whitespaces)
            let vendorFee = columns[15].trimmingCharacters(in: .whitespaces)
            
            // Skip rows where essential fields (name or location) are empty
            guard !name.isEmpty || !location.isEmpty else { continue }
            
            let show = CarShow(
                rowOrder: rowOrder,
                date: date,
                club: club,
                name: name,
                time: time,
                description: description,
                location: location,
                address: address,
                carFee: carFee,
                spectatorFee: spectatorFee,
                notes: notes,
                contact: contact,
                email: email,
                website: website,
                rainDate: rainDate,
                vendors: vendors,
                vendorFee: vendorFee
            )
            
            // Only add shows that are today or in the future
            if show.isUpcoming {
                shows.append(show)
                rowOrder += 1  // Increment for next valid row
            }
        }
        
        return shows
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

// MARK: - Car Show Card Component
struct CarShowCard: View {
    let carShow: CarShow
    
    // Check if the date field says "Rain Dates"
    private var isRainDateRecord: Bool {
        return carShow.date.trimmingCharacters(in: .whitespaces).lowercased() == "rain dates"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            // Column 1: DATE
            if !carShow.date.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.subheadline)
                    Text(carShow.date)
                        //.font(.subheadline)
                        //.fontWeight(.semibold)
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Column 2: CLUB
            if !carShow.club.isEmpty {
                Text(carShow.club)
                    .font(.subheadline)
            }
            
            // Column 3: NAME (with rain date styling if applicable)
            if !carShow.name.isEmpty {
                HStack(spacing: 4) {
                    Text(carShow.name)
                        .font(.subheadline)
                        .bold()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
            
            
            // Column 4: TIME
            if !carShow.time.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.subheadline)
                    Text(carShow.time)
                        .font(.subheadline)
                        .bold()
                        //.padding(.horizontal, 8)
                        //.padding(.vertical, 4)
                        //.background(Color.red)
                        //.foregroundColor(.white)
                        //.cornerRadius(6)
                }
            }
            
            // Column 5: DESCRIPTION
            if !carShow.description.isEmpty {
                Text(carShow.description)
                    .font(.subheadline)
            }
            
            // Column 6: LOCATION
            if !carShow.location.isEmpty {
                Text(carShow.location)
                    .font(.headline)
            }
            
            // Column 7: ADDRESS (with map link)
            if !carShow.address.isEmpty {
                Button(action: {
                    openInMaps()
                }) {
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.red)
                        Text(carShow.address)
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
            
            // Column 8: CAR FEE
            if !carShow.carFee.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "dollarsign.circle")
                        .font(.subheadline)
                    Text("Car: \(carShow.carFee)")
                        .font(.subheadline)
                }
            }
            
            // Column 9: SPECTATOR FEE
            if !carShow.spectatorFee.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "dollarsign.circle")
                        .font(.subheadline)
                    Text("Spectator: \(carShow.spectatorFee)")
                        .font(.subheadline)
                }
            }
            
            // Column 10: NOTES
            if !carShow.notes.isEmpty {
                Text(carShow.notes)
                    .font(.subheadline)
            }
            
            // Column 11: CONTACT
            if !carShow.contact.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "phone")
                        .font(.subheadline)
                    Text(carShow.contact)
                        .font(.subheadline)
                }
            }
            
            // Column 12: EMAIL
            if !carShow.email.isEmpty {
                Link(destination: URL(string: "mailto:\(carShow.email)") ?? URL(string: "https://www.apple.com")!) {
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "envelope")
                            .font(.subheadline)
                        Text(carShow.email)
                            .font(.subheadline)
                            .lineLimit(1)
                        Image(systemName: "arrow.up.right.square")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Column 13: WEBSITE
            if !carShow.website.isEmpty {
                Link(destination: URL(string: carShow.website.hasPrefix("http") ? carShow.website : "https://\(carShow.website)") ?? URL(string: "https://www.apple.com")!) {
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "link")
                            .font(.subheadline)
                        Text(carShow.website)
                            .font(.subheadline)
                            .lineLimit(1)
                        Image(systemName: "arrow.up.right.square")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Column 14: RAIN DATE
            if !carShow.rainDate.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "cloud.rain")
                        .font(.subheadline)
                    Text("Rain Date: \(carShow.rainDate)")
                        .font(.subheadline)
                }
            }
            
            // Column 15 & 16: VENDORS and VENDOR FEE
            if !carShow.vendors.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "car.circle")
                        .font(.subheadline)
                    Text("Vendors: \(carShow.vendors)")
                        .font(.subheadline)
                }
            }
            
            if !carShow.vendorFee.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle")
                        .font(.subheadline)
                    Text("Vendor Fee: \(carShow.vendorFee)")
                        .font(.subheadline)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isRainDateRecord ? Color.gray.opacity(0.2) : Color.clear)
        )
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isRainDateRecord ? Color.gray : Color.clear, lineWidth: 2)
        )
    }
    
    private func openInMaps() {
        let encodedLocation = carShow.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
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

#Preview("Full App - ContentView") {
    ContentView()
}


