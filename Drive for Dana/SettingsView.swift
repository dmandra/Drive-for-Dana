//
//  SettingsView.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 3/4/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingClearCacheAlert = false
    @State private var cacheCleared = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text("SETTINGS")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                
                // Network Status
                HStack {
                    Image(systemName: dataManager.isOnline ? "wifi" : "wifi.slash")
                        .foregroundColor(dataManager.isOnline ? .green : .red)
                    Text("Network Status:")
                        .font(.headline)
                    Spacer()
                    Text(dataManager.isOnline ? "Online" : "Offline")
                        .foregroundColor(dataManager.isOnline ? .green : .red)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                
                Divider()
                    .padding(.vertical, 8)
                
                // Cache Management
                Text("CACHE MANAGEMENT")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                Text("The app stores Car Shows and Cruise Nights locally so you can view them offline. Data is automatically refreshed when online.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                Button(action: {
                    showingClearCacheAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear All Cached Data")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
                .alert("Clear Cache?", isPresented: $showingClearCacheAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Clear", role: .destructive) {
                        dataManager.clearAllCache()
                        cacheCleared = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            cacheCleared = false
                        }
                    }
                } message: {
                    Text("This will remove all cached Car Shows and Cruise Nights. The app will need to fetch data from the internet again.")
                }
                
                if cacheCleared {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Cache cleared successfully")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    .transition(.opacity)
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // About
                //Text("ABOUT")
                    //.font(.headline)
                    //.padding(.bottom, 4)
                
                //VStack(alignment: .leading, spacing: 8) {
                    //Text("Drive for Dana")
                        //.font(.body)
                        //.bold()
                    
                    //Text("Version 1.6.3")
                        //.font(.subheadline)
                        //.foregroundColor(.secondary)
                    
                    //Text("Car Shows and Cruise Nights / Cars & Coffee Information for Long Island")
                       // .font(.subheadline)
                        //.foregroundColor(.secondary)
               // }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }
}

#Preview {
    SettingsView()
}
