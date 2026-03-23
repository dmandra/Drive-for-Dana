//
//  ContactUsView.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 3/1/26.
//

import SwiftUI

struct ContactUsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                Text("CONTACT US")
                    .font(.title2)
                    .bold()
                    //.frame(maxWidth: .infinity, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)
                
                // Information items
                Text("Become a Sponsor")
                    .font(.body)
                
                Text("Make a Correction to an Event")
                    .font(.body)
                
                Text("Add a Cruise Night/Cars & Coffee")
                    .font(.body)
                
                Text("Report App Issues")
                    .font(.body)
                
                Divider()
                    .padding(.vertical, 4)
                
                // Drive for Dana Foundation section
                Text("DRIVE FOR DANA FOUNDATION")
                    .font(.headline)
                    .bold()
                    .padding(.bottom, 2)
                
                Text("Nicholas Ferraioli")
                    .font(.body)
                
                // Phone number link
                Button(action: {
                    if let url = URL(string: "tel://6315536975") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                            .font(.subheadline)
                        Text("Phone: (631) 553-6975")
                            .font(.body)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)
                
                // Email link
                Link(destination: URL(string: "mailto:drivefordana@hotmail.com")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "envelope.fill")
                            .font(.subheadline)
                        Text("Email: drivefordana@hotmail.com")
                            .font(.body)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundColor(.blue)
                
                // Website link
                Link(destination: URL(string: "https://www.drivefordana.org")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.subheadline)
                        Text("Website: www.drivefordana.org")
                            .font(.body)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundColor(.blue)
                
                Divider()
                    .padding(.vertical, 4)
                
                // App Developer section
                Text("App Developer")
                    .font(.headline)
                    .bold()
                    .padding(.bottom, 2)
                
                Text("Donald Mandra")
                    .font(.body)
                
                // Developer email link
                Link(destination: URL(string: "DFDcarshows@gmail.com")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "envelope.fill")
                            .font(.subheadline)
                        Text("Email: DFDcarshows@gmail.com")
                            .font(.body)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundColor(.blue)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        
    }
}

#Preview {
    ContactUsView()
}
