//
//  DataManager.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 3/4/26.
//

import Foundation
import Network
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var isOnline: Bool = true
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        setupNetworkMonitoring()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    // MARK: - Car Shows Storage
    
    func saveCarShows(_ shows: [CarShow], for monthIndex: Int) {
        let key = "carShows_\(monthIndex)"
        if let encoded = try? JSONEncoder().encode(shows) {
            UserDefaults.standard.set(encoded, forKey: key)
            // Also save the timestamp
            UserDefaults.standard.set(Date(), forKey: "\(key)_timestamp")
        }
    }
    
    func loadCarShows(for monthIndex: Int) -> [CarShow]? {
        let key = "carShows_\(monthIndex)"
        guard let data = UserDefaults.standard.data(forKey: key),
              let shows = try? JSONDecoder().decode([CarShow].self, from: data) else {
            return nil
        }
        return shows
    }
    
    func getCarShowsTimestamp(for monthIndex: Int) -> Date? {
        let key = "carShows_\(monthIndex)_timestamp"
        return UserDefaults.standard.object(forKey: key) as? Date
    }
    
    // MARK: - Cruise Nights Storage
    
    func saveCruiseNights(_ nights: [CruiseNight], for dayIndex: Int) {
        let key = "cruiseNights_\(dayIndex)"
        if let encoded = try? JSONEncoder().encode(nights) {
            UserDefaults.standard.set(encoded, forKey: key)
            // Also save the timestamp
            UserDefaults.standard.set(Date(), forKey: "\(key)_timestamp")
        }
    }
    
    func loadCruiseNights(for dayIndex: Int) -> [CruiseNight]? {
        let key = "cruiseNights_\(dayIndex)"
        guard let data = UserDefaults.standard.data(forKey: key),
              let nights = try? JSONDecoder().decode([CruiseNight].self, from: data) else {
            return nil
        }
        return nights
    }
    
    func getCruiseNightsTimestamp(for dayIndex: Int) -> Date? {
        let key = "cruiseNights_\(dayIndex)_timestamp"
        return UserDefaults.standard.object(forKey: key) as? Date
    }
    
    // MARK: - Cache Management
    
    func clearAllCache() {
        // Clear all car shows
        for monthIndex in 0..<12 {
            let key = "carShows_\(monthIndex)"
            UserDefaults.standard.removeObject(forKey: key)
            UserDefaults.standard.removeObject(forKey: "\(key)_timestamp")
        }
        
        // Clear all cruise nights
        for dayIndex in 0..<7 {
            let key = "cruiseNights_\(dayIndex)"
            UserDefaults.standard.removeObject(forKey: key)
            UserDefaults.standard.removeObject(forKey: "\(key)_timestamp")
        }
    }
    
    func shouldRefreshCache(for timestamp: Date?, maxAge: TimeInterval = 86400) -> Bool {
        // Default refresh every hour (3600 seconds)
        guard let timestamp = timestamp else { return true }
        return Date().timeIntervalSince(timestamp) > maxAge
    }
    
    // MARK: - Preload All Data
    
    func preloadAllData() async {
        guard isOnline else { 
            print("⚠️ Preload skipped: Device is offline")
            return 
        }
        
        print("📥 Preloading all car shows (12 months)...")
        
        // Preload all car shows (12 months)
        await withTaskGroup(of: Void.self) { group in
            for monthIndex in 0..<12 {
                group.addTask {
                    await self.preloadCarShows(for: monthIndex)
                }
            }
        }
        
        print("📥 Preloading all cruise nights (7 days)...")
        
        // Preload all cruise nights (7 days)
        await withTaskGroup(of: Void.self) { group in
            for dayIndex in 0..<7 {
                group.addTask {
                    await self.preloadCruiseNights(for: dayIndex)
                }
            }
        }
        
        print("✅ Preload completed!")
    }
    
    private func preloadCarShows(for monthIndex: Int) async {
        let monthNames = Calendar.current.monthSymbols
        let monthName = monthNames[monthIndex]
        
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
            print("⚠️ No GID for month \(monthName)")
            return 
        }
        
        let csvURL = "https://docs.google.com/spreadsheets/d/\(spreadsheetId)/export?format=csv&gid=\(gid)"
        guard let url = URL(string: csvURL) else { 
            print("❌ Invalid URL for month \(monthName)")
            return 
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let csvString = String(data: data, encoding: .utf8) else { 
                print("❌ Failed to parse CSV for month \(monthName)")
                return 
            }
            
            let shows = parseCarShowsCSV(csvString, monthIndex: monthIndex)
            saveCarShows(shows, for: monthIndex)
            print("✅ Cached \(shows.count) car shows for \(monthName)")
        } catch {
            // Silently fail - preloading is optional
            print("❌ Failed to preload car shows for \(monthName): \(error.localizedDescription)")
        }
    }
    
    private func preloadCruiseNights(for dayIndex: Int) async {
        let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let dayName = daysOfWeek[dayIndex]
        
        let spreadsheetId = "1zSDlFOtKubbo3OCFIz2c-2NWyj49k6CWvHBmB3GQfm0"
        
        let sheetGids: [Int: String] = [
            0: "1793929430",  // Sunday
            1: "0",           // Monday
            2: "1908585593",  // Tuesday
            3: "1745799873",  // Wednesday
            4: "837886919",   // Thursday
            5: "2033559366",  // Friday
            6: "354667709"    // Saturday
        ]
        
        guard let gid = sheetGids[dayIndex], !gid.isEmpty else { 
            print("⚠️ No GID for day \(dayName)")
            return 
        }
        
        let csvURL = "https://docs.google.com/spreadsheets/d/\(spreadsheetId)/export?format=csv&gid=\(gid)"
        guard let url = URL(string: csvURL) else { 
            print("❌ Invalid URL for day \(dayName)")
            return 
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let csvString = String(data: data, encoding: .utf8) else { 
                print("❌ Failed to parse CSV for day \(dayName)")
                return 
            }
            
            let nights = parseCruiseNightsCSV(csvString, dayIndex: dayIndex)
            saveCruiseNights(nights, for: dayIndex)
            print("✅ Cached \(nights.count) cruise nights for \(dayName)")
        } catch {
            // Silently fail - preloading is optional
            print("❌ Failed to preload cruise nights for \(dayName): \(error.localizedDescription)")
        }
    }
    
    private func parseCarShowsCSV(_ csv: String, monthIndex: Int) -> [CarShow] {
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
    
    private func parseCruiseNightsCSV(_ csv: String, dayIndex: Int) -> [CruiseNight] {
        let rows = csv.components(separatedBy: .newlines)
        var nights: [CruiseNight] = []
        var rowOrder = 0
        
        for (index, row) in rows.enumerated() {
            guard index > 0, !row.isEmpty else { continue }
            
            let columns = parseCSVRow(row)
            guard columns.count >= 6 else { continue }
            
            let clubName = columns[0].trimmingCharacters(in: .whitespaces)
            let name = columns[1].trimmingCharacters(in: .whitespaces)
            let location = columns[2].trimmingCharacters(in: .whitespaces)
            let time = columns[3].trimmingCharacters(in: .whitespaces)
            let dates = columns[4].trimmingCharacters(in: .whitespaces)
            let notes = columns[5].trimmingCharacters(in: .whitespaces)
            
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
            rowOrder += 1
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
        
        columns.append(currentColumn)
        return columns
    }
}
