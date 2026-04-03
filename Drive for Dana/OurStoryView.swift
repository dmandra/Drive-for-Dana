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
                    .font(.title2)
                    .bold()
                    //.frame(maxWidth: .infinity, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)
                
                // Information items
                //Text("Become a Sponsor")
                    //.font(.body)
                
                //Text("Make a Correction to an Event")
                    //.font(.body)
                
                //Text("Add a Cruise Night/Cars & Coffee")
                    //.font(.body)
                
                //Text("Report App Issues")
                    //.font(.body)
                
                //Divider()
                    //.padding(.vertical, 4)
                
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
                Text("DRIVE FOR DANA FOUNDATION")
                    .font(.headline)
                    .bold()
                    .padding(.bottom, 2)
                Text("Drive For Dana is a 501c3 charity that helps medically fragile children. We started our journey shortly after Dana suffered a traumatic brain injury from a near fatal drowning accident in 2018.")
                    .font(.body)
                Text("We started with a very small car show and have grown to a weekly cars and coffee as well as one of the largest car shows on Long Island and a Winter Breakfast for the whole family.")
                    .font(.body)
                Text("The Drive For Dana Team prides itself on being 100% volunteer with every dollar donated at events going back out to children.")
                    .font(.body)
                Text("The Drive For Dana Foundation is dedicated to continuing Dana’s legacy of bringing awareness to the medically fragile community on Long Island.")
                    .font(.body)
                
                Divider()
                    .padding(.vertical, 4)
                
                // Phone number link
                //Button(action: {
                    //if let url = URL(string: "tel://6315536975") {
                        //UIApplication.shared.open(url)
                    //}
                //}) {
                    //HStack(spacing: 4) {
                        //Image(systemName: "phone.fill")
                            //.font(.subheadline)
                        //Text("Phone: (631) 553-6975")
                            //.font(.body)
                        //Spacer()
                        //Image(systemName: "arrow.up.right.square")
                            //.font(.subheadline)
                    //}
                    //.frame(maxWidth: .infinity, alignment: .leading)
                //}
                //.buttonStyle(.plain)
                //.foregroundColor(.blue)
                
                // Email link
                //Link(destination: URL(string: "mailto:drivefordana@hotmail.com")!) {
                    //HStack(spacing: 4) {
                        //Image(systemName: "envelope.fill")
                            //.font(.subheadline)
                        //Text("Email: drivefordana@hotmail.com")
                            //.font(.body)
                        //Spacer()
                        //Image(systemName: "arrow.up.right.square")
                            //.font(.subheadline)
                    //}
                    //.frame(maxWidth: .infinity, alignment: .leading)
                //}
                //.foregroundColor(.blue)
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
