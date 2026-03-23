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
            VStack(spacing: 0) {
                // Fixed header section with date picker and search button inline
                Form {
                    Section {
                        //add space between date and search button
                        HStack(spacing: 18) {
                            DatePicker(
                                "",
                                selection: $searchDate,
                                displayedComponents: [.date]
                            )
                            .labelsHidden()
                            
                            Spacer()
                            
                            Button(action: {
                                performSearch()
                            }) {
                                if isSearching {
                                    ProgressView()
                                        .frame(width: 30, height: 30)
                                } else {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .frame(width: 80, height: 40)
                                        .background(Color.accentColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                            }
                            .disabled(isSearching)
                        }
                    }
                    .listRowBackground(Color.blue.opacity(0.1))
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                //added two lines to test
                .minimumScaleFactor(0.5)
                .frame(height: 80)
                //original
                //.frame(height: 100)
                .scrollDisabled(true)
                
                Divider()
                
                // Scrollable results section
                ScrollView {
                    VStack(spacing: 16) {
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
                                .padding()
                                .padding(.top, 40)
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(searchResults.count) Car Show\(searchResults.count == 1 ? "" : "s") Found")
                                        .font(.headline)
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                    
                                    VStack(spacing: 4) {
                                        ForEach(searchResults) { show in
                                            CarShowCard(carShow: show)
                                            Divider()
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        } else {
                            // Initial state instructions
                            VStack(spacing: 16) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                                
                                VStack(spacing: 8) {
                                    Text("Search for Car Shows by Date")
                                        .font(.headline)
                                    
                                    Text("Select a date above and tap the search button to find car shows scheduled for that day.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                    
                                    //Text("Most car shows are on Saturday and Sunday")
                                        //.font(.caption)
                                        //.foregroundStyle(.secondary)
                                        //.italic()
                                        //.padding(.top, 4)
                                }
                                .padding(.horizontal, 32)
                            }
                            .padding()
                            .padding(.top, 40)
                        }
                    }
                    .padding(.bottom)
                }
            }
            //added next line to reduce spacing below title and date picker
            .contentMargins(.top, 10)
            //original
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
