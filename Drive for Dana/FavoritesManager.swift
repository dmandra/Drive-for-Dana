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
        favoriteCarShows = shows
    }
    
    // MARK: - Save Favorites
    
    private func saveFavorites() {
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
}
