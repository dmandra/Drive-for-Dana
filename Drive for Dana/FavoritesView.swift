//
//  FavoritesView.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 3/7/26.
//

import SwiftUI
import CoreLocation
import WeatherKit

// MARK: - Identifiable CLLocation Wrapper
struct IdentifiableLocation: Identifiable {
    let id = UUID()
    let location: CLLocation
    let address: String
}

struct FavoritesView: View {
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            if favoritesManager.favoriteCarShows.isEmpty {
                // Empty state
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "star.slash")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No Favorites Saved")
                        .font(.headline)
                    Text("Add Favorites from Car Shows")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 4) {
                        // Header text
                        Text("Car Show Saved Favorites")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        ForEach(favoritesManager.favoriteCarShows) { show in
                            FavoriteCarShowCard(carShow: show)
                            
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
    }
}

// MARK: - Favorite Car Show Card with Delete Button
struct FavoriteCarShowCard: View {
    let carShow: CarShow
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @State private var showDeleteConfirmation = false
    @State private var weatherItem: IdentifiableLocation?
    @State private var isGeocodingAddress = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            // Column 1: DATE
            if !carShow.date.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.subheadline)
                    Text(carShow.date)
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
            
            // Column 3: NAME
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
                        Spacer()
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
                        Spacer()
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
                    Image(systemName: "dollarsign.circle")
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
            
            // Weather and Remove Buttons (side by side)
            HStack(spacing: 8) {
                // Check Weather Button (only show if address exists)
                if !carShow.address.isEmpty {
                    Button(action: {
                        openInWeather()
                    }) {
                        HStack {
                            if isGeocodingAddress {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Image(systemName: "cloud.sun")
                            }
                            Text("Weather")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                    .disabled(isGeocodingAddress)
                }
                
                // Delete Button
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Remove")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
                .alert("Remove from Favorites?", isPresented: $showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Remove", role: .destructive) {
                        favoritesManager.removeFavorite(carShow)
                    }
                } message: {
                    Text("Are you sure you want to remove \"\(carShow.name)\" from your favorites?")
                }
            }
            .padding(.top, 4)
        }
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .sheet(item: $weatherItem) { item in
            WeatherView(location: item.location, address: item.address)
        }
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
    
    private func openInWeather() {
        // Show loading indicator
        isGeocodingAddress = true
        
        // Geocode the address to get coordinates for WeatherKit
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(carShow.address) { placemarks, error in
            DispatchQueue.main.async {
                // Hide loading indicator
                self.isGeocodingAddress = false
                
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    return
                }
                
                guard let placemark = placemarks?.first,
                      let location = placemark.location else {
                    print("No location found for address")
                    return
                }
                
                // Create identifiable location item - this will trigger the sheet to present
                self.weatherItem = IdentifiableLocation(location: location, address: self.carShow.address)
            }
        }
    }
}

// MARK: - Weather View
struct WeatherView: View {
    let location: CLLocation
    let address: String
    @Environment(\.dismiss) private var dismiss
    @State private var weather: Weather?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var weatherAttribution: WeatherAttribution?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading weather...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Unable to load weather")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else if let weather = weather {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Location
                            VStack(alignment: .leading, spacing: 4) {
                                Text(address)
                                    .font(.headline)
                                Text("10-Day Forecast")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                            
                            // Current Weather
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: weather.currentWeather.symbolName)
                                        .font(.system(size: 60))
                                        .symbolRenderingMode(.multicolor)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(weather.currentWeather.temperature.formatted(.measurement(width: .abbreviated, usage: .weather, numberFormatStyle: .number.precision(.fractionLength(0)))))
                                            .font(.system(size: 48, weight: .thin))
                                        Text(weather.currentWeather.condition.description)
                                            .font(.title3)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal)
                            
                            // Daily Forecast
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Daily Forecast")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(weather.dailyForecast, id: \.date) { day in
                                    HStack {
                                        Text(day.date, format: .dateTime.weekday(.abbreviated).month().day())
                                            .frame(width: 80, alignment: .leading)
                                        
                                        Image(systemName: day.symbolName)
                                            .symbolRenderingMode(.multicolor)
                                            .frame(width: 40)
                                        
                                        Text(day.condition.description)
                                            .font(.subheadline)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(day.lowTemperature.formatted(.measurement(width: .abbreviated, usage: .weather, numberFormatStyle: .number.precision(.fractionLength(0)))))
                                            .foregroundStyle(.secondary)
                                        
                                        Text("/")
                                            .foregroundStyle(.secondary)
                                        
                                        Text(day.highTemperature.formatted(.measurement(width: .abbreviated, usage: .weather, numberFormatStyle: .number.precision(.fractionLength(0)))))
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                    
                                    if day.date != weather.dailyForecast.last?.date {
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.vertical)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                            
                            // MARK: - Weather Attribution (Required by Apple)
                            if let attribution = weatherAttribution {
                                VStack(spacing: 8) {
                                    Divider()
                                        .padding(.horizontal)
                                    
                                    Link(destination: attribution.legalPageURL) {
                                        HStack(spacing: 8) {
                                            // Display the weather service logo
                                            if let logoImage = combinedAttributionImage(
                                                lightLogo: attribution.combinedMarkLightURL,
                                                darkLogo: attribution.combinedMarkDarkURL
                                            ) {
                                                logoImage
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 20)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "arrow.up.right.square")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 20)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadWeather()
            }
        }
    }
    
    private func loadWeather() async {
        do {
            let weatherService = WeatherService.shared
            let weather = try await weatherService.weather(for: location)
            
            // Load weather attribution
            let attribution = try await weatherService.attribution
            
            await MainActor.run {
                self.weather = weather
                self.weatherAttribution = attribution
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("Weather error: \(error)")
        }
    }
    
    // Helper function to load and display the attribution logo based on color scheme
    private func combinedAttributionImage(lightLogo: URL, darkLogo: URL) -> Image? {
        @Environment(\.colorScheme) var colorScheme
        
        let logoURL = colorScheme == .dark ? darkLogo : lightLogo
        
        // Load the image from URL
        guard let data = try? Data(contentsOf: logoURL),
              let uiImage = UIImage(data: data) else {
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
}

#Preview {
    FavoritesView()
}
