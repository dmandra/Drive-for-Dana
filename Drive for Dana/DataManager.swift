//
//  DataManager.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 3/4/26.
//

import Foundation
import Network

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
    
    func shouldRefreshCache(for timestamp: Date?, maxAge: TimeInterval = 3600) -> Bool {
        // Default refresh every hour (3600 seconds)
        guard let timestamp = timestamp else { return true }
        return Date().timeIntervalSince(timestamp) > maxAge
    }
}
