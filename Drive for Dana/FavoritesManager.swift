//
//  FavoritesManager.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 3/7/26.
//

import Foundation
import Combine

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteCarShows: [CarShow] = []
    
    private let favoritesKey = "favoriteCarShows"
    
    private init() {
        loadFavorites()
    }
    
    // MARK: - Load Favorites
    
    func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let shows = try? JSONDecoder().decode([CarShow].self, from: data) else {
            favoriteCarShows = []
            return
        }
        favoriteCarShows = sortByDate(shows)
    }
    
    // MARK: - Save Favorites
    
    private func saveFavorites() {
        // Sort before saving
        favoriteCarShows = sortByDate(favoriteCarShows)
        
        if let encoded = try? JSONEncoder().encode(favoriteCarShows) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    // MARK: - Add to Favorites
    
    func addFavorite(_ show: CarShow) {
        // Check if already favorited
        guard !isFavorite(show) else { return }
        
        favoriteCarShows.append(show)
        saveFavorites()
    }
    
    // MARK: - Remove from Favorites
    
    func removeFavorite(_ show: CarShow) {
        favoriteCarShows.removeAll { $0.id == show.id }
        saveFavorites()
    }
    
    // MARK: - Check if Favorite
    
    func isFavorite(_ show: CarShow) -> Bool {
        return favoriteCarShows.contains { $0.id == show.id }
    }
    
    // MARK: - Toggle Favorite
    
    func toggleFavorite(_ show: CarShow) {
        if isFavorite(show) {
            removeFavorite(show)
        } else {
            addFavorite(show)
        }
    }
    
    // MARK: - Date Sorting Helper
    
    private func sortByDate(_ shows: [CarShow]) -> [CarShow] {
        return shows.sorted { show1, show2 in
            guard let date1 = parseDate(show1.date),
                  let date2 = parseDate(show2.date) else {
                // If dates can't be parsed, maintain original order
                return show1.rowOrder < show2.rowOrder
            }
            return date1 < date2
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        // Try multiple date formats
        let formatters = [
            createFormatter(format: "MM/dd/yyyy"),      // e.g., "03/15/2026"
            createFormatter(format: "M/d/yyyy"),        // e.g., "3/15/2026"
            createFormatter(format: "MM/dd/yy"),        // e.g., "03/15/26"
            createFormatter(format: "M/d/yy"),          // e.g., "3/15/26"
            createFormatter(format: "MMMM d, yyyy"),    // e.g., "March 15, 2026"
            createFormatter(format: "MMM d, yyyy")      // e.g., "Mar 15, 2026"
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    private func createFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}
