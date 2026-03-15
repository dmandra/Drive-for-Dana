//
//  CarShowSearchView.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 3/15/26.
//

import SwiftUI

struct CarShowSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchDate = Date()
    @State private var searchResults: [CarShow] = []
    @State private var isSearching = false
    @State private var hasSearched = false
    @ObservedObject private var dataManager = DataManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Date")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    DatePicker(
                        "Search Date",
                        selection: $searchDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                }
                
                // Search Button
                Button(action: {
                    performSearch()
                }) {
                    HStack {
                        if isSearching {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                        Text("Search Car Shows")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isSearching)
                .padding(.horizontal)
                
                // Results
                if hasSearched {
                    if searchResults.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("No car shows found")
                                .font(.headline)
                            Text("Try searching for a different date")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxHeight: .infinity)
                        .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(searchResults.count) car show\(searchResults.count == 1 ? "" : "s") found")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView {
                                VStack(spacing: 4) {
                                    ForEach(searchResults) { show in
                                        CarShowCard(carShow: show)
                                        Divider()
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }
                    }
                } else {
                    Spacer()
                }
            }
            .padding(.top)
            .navigationTitle("Search Car Shows")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func performSearch() {
        Task {
            isSearching = true
            hasSearched = true
            
            // Get the search date components
            let calendar = Calendar.current
            let searchDay = calendar.startOfDay(for: searchDate)
            
            var allShows: [CarShow] = []
            
            // Load car shows from all months
            for monthIndex in 0..<12 {
                // First try to load from cache
                if let cachedShows = dataManager.loadCarShows(for: monthIndex) {
                    allShows.append(contentsOf: cachedShows)
                } else if dataManager.isOnline {
                    // If not cached and we're online, try to fetch from network
                    if let fetchedShows = await fetchCarShowsFromNetwork(for: monthIndex) {
                        allShows.append(contentsOf: fetchedShows)
                    }
                }
            }
            
            // Filter shows by the search date
            searchResults = allShows.filter { show in
                guard let showDate = show.parsedDate else {
                    return false
                }
                
                let showDay = calendar.startOfDay(for: showDate)
                return showDay == searchDay
            }
            
            isSearching = false
        }
    }
    
    private func fetchCarShowsFromNetwork(for monthIndex: Int) async -> [CarShow]? {
        let spreadsheetId = "1WBhNXkVSf9VVjVM9Dfw6mG31gVM877kuSM0kioOHjus"
        
        let sheetGids: [Int: String] = [
            0: "1081313977",  // January
            1: "1692556642",  // February
            2: "722941395",   // March
            3: "858423076",   // April
            4: "1122570857",  // May
            5: "1881219469",  // June
            6: "186732713",   // July
            7: "1338027119",  // August
            8: "1839427359",  // September
            9: "1155943106",  // October
            10: "1592260621", // November
            11: "342572286"   // December
        ]
        
        guard let gid = sheetGids[monthIndex], !gid.isEmpty else {
            return nil
        }
        
        let csvURL = "https://docs.google.com/spreadsheets/d/\(spreadsheetId)/export?format=csv&gid=\(gid)"
        
        guard let url = URL(string: csvURL) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let csvString = String(data: data, encoding: .utf8) else {
                return nil
            }
            
            let shows = parseCSV(csvString)
            
            // Save to cache for future use
            dataManager.saveCarShows(shows, for: monthIndex)
            
            return shows
        } catch {
            return nil
        }
    }
    
    private func parseCSV(_ csv: String) -> [CarShow] {
        let rows = csv.components(separatedBy: .newlines)
        var shows: [CarShow] = []
        var rowOrder = 0
        
        for (index, row) in rows.enumerated() {
            guard index > 0, !row.isEmpty else { continue }
            
            let columns = parseCSVRow(row)
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
            
            if show.isUpcoming {
                shows.append(show)
                rowOrder += 1
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
        
        columns.append(currentColumn)
        return columns
    }
}

#Preview {
    CarShowSearchView()
}
