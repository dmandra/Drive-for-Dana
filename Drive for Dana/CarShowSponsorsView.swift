//
//  CarShowSponsorsView.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 2/26/26.
//

import SwiftUI
import Combine

// MARK: - Car Show Sponsors View
struct CarShowSponsorsView: View {
    @State private var sponsors: [Sponsor] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView("Loading sponsors...")
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Unable to load sponsors")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            await loadSponsors()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                Spacer()
            } else if sponsors.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "heart.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No sponsors listed")
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
                            Text("CAR SHOW SPONSORS")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Thank you to our amazing car show sponsors who make our annual event possible!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Sponsors list
                        ForEach(sponsors) { sponsor in
                            SponsorCard(sponsor: sponsor)
                            
                            Divider()
                        }
                        
                        // Footer text
                        VStack(spacing: 8) {
                            Text("🚗 BECOME A CAR SHOW SPONSOR")
                                .font(.headline)
                            
                            Text("Interested in supporting our annual car show? Contact us to learn about sponsorship opportunities!")
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
            await loadSponsors()
        }
    }
    
    private func loadSponsors() async {
        isLoading = true
        errorMessage = nil
        
        // Spreadsheet ID from your Car Show Sponsors URL
        let spreadsheetId = "1-xDnx89A4PfBJPL3EeQwEOUYHYHplZmRtoN1IyzE-38"
        
        // Using gid=0 for the first sheet
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
            
            sponsors = parseCSV(csvString)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    private func parseCSV(_ csv: String) -> [Sponsor] {
        let rows = csv.components(separatedBy: .newlines)
        var parsedSponsors: [Sponsor] = []
        var rowOrder = 0  // Track order
        
        // Skip header row (index 0) and parse data rows
        for (index, row) in rows.enumerated() {
            guard index > 0, !row.isEmpty else { continue }
            
            // Parse CSV row (handle quoted fields that may contain commas)
            let columns = parseCSVRow(row)
            
            // Expecting 6 columns: Name, Address, Description, Contact, Email, Website
            guard columns.count >= 6 else { continue }
            
            let name = columns[0].trimmingCharacters(in: .whitespaces)
            let address = columns[1].trimmingCharacters(in: .whitespaces)
            let description = columns[2].trimmingCharacters(in: .whitespaces)
            let contact = columns[3].trimmingCharacters(in: .whitespaces)
            let email = columns[4].trimmingCharacters(in: .whitespaces)
            let website = columns[5].trimmingCharacters(in: .whitespaces)
            
            // Skip rows where essential fields (name) are empty
            guard !name.isEmpty else { continue }
            
            let sponsor = Sponsor(
                rowOrder: rowOrder,
                name: name,
                address: address,
                description: description,
                contact: contact,
                email: email,
                website: website
            )
            
            parsedSponsors.append(sponsor)
            rowOrder += 1  // Increment for next valid row
        }
        
        return parsedSponsors
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

// MARK: - Previews
#Preview("Car Show Sponsors View") {
    CarShowSponsorsView()
}

#Preview("Full App - ContentView") {
    ContentView()
}
