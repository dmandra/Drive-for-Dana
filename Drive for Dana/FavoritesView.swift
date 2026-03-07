//
//  FavoritesView.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 3/7/26.
//

import SwiftUI

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
                        Text("Car Show Favorites")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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
            
            // Delete Button
            Button(action: {
                showDeleteConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Remove from Favorites")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(8)
            }
            .padding(.top, 4)
            .alert("Remove from Favorites?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    favoritesManager.removeFavorite(carShow)
                }
            } message: {
                Text("Are you sure you want to remove \"\(carShow.name)\" from your favorites?")
            }
        }
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
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

#Preview {
    FavoritesView()
}
