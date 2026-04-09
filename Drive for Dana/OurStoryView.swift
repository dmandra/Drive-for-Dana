//
//  ContactUsView.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 3/1/26.
//

import SwiftUI

struct OurStoryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {

                // Header
                Text("OUR STORY")
                    .font(.system(size: 20, weight: .bold))
                    //.frame(maxWidth: .infinity, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)
                
                // Information items
                Text("If you are enjoying this app and would like to support the Drive For Dana Foundation, please consider making a donation.")
                    .font(.system(size: 16, weight: .regular))
                    //.foregroundStyle(.secondary)
                
                // Zeffy link
                Link(destination: URL(string: "https://www.zeffy.com/en-US/donation-form/78541d04-41af-47eb-ba42-033f70c53097")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "giftcard.fill")
                            .font(.subheadline)
                        Text("Please Donate")
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
                
                // Drive for Dana Foundation section
                Text("Long Island Car Shows & Cruise Nights")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.bottom, 2)
                Text("DFD / Long Island Car Shows & Cruise Nights is built for enthusiasts who want a simple, reliable way to find local car events. This app brings together Car Shows, Cruise Nights / Cars & Coffee, and Special Events across Long Island in one easy to use app.")
                    .font(.system(size: 16, weight: .regular))
                //.font(.body)
                
                Divider()
                    .padding(.vertical, 4)
                
                // Drive for Dana Foundation section
                Text("Drive For Dana Foundation")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.bottom, 2)
                Text("Drive For Dana is a 501c3 charity that helps medically fragile children. We started our journey shortly after Dana suffered a traumatic brain injury from a near fatal drowning accident in 2018.")
                    .font(.system(size: 16, weight: .regular))
                Text("We started with a very small car show and have grown to a weekly cars and coffee as well as one of the largest car shows on Long Island and a Winter Breakfast for the whole family.")
                    .font(.system(size: 16, weight: .regular))
                Text("The Drive For Dana Team prides itself on being 100% volunteer with every dollar donated at events going back out to children.")
                    .font(.system(size: 16, weight: .regular))
                Text("The Drive For Dana Foundation is dedicated to continuing Dana’s legacy of bringing awareness to the medically fragile community on Long Island.")
                    .font(.system(size: 16, weight: .regular))
                
                Divider()
                    .padding(.vertical, 4)

            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        
    }
}

#Preview {
    OurStoryView()
}
