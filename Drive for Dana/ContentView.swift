//
//  ContentView.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 2/22/26.

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var urlString: String?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let urlString = urlString, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

struct ContentView: View {
    @State private var selection: Selection = .home  // Always start on Home
    @State private var linkSelection: LinkAction? = nil
    @State private var homeImageSelection: HomeImageOption = .welcome
    @State private var monthIndex: Int = Calendar.current.component(.month, from: Date()) - 1
    @State private var dayOfWeekIndex: Int = {
        // Get current day of week (1 = Sunday, 7 = Saturday) and convert to 0-based index
        let currentDayNumber = Calendar.current.component(.weekday, from: Date())
        return currentDayNumber - 1
    }()
    @State private var showingManagement = false
    private let months: [String] = Calendar.current.monthSymbols
    private let daysOfWeek: [String] = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    private enum Selection: String, CaseIterable, Identifiable {
        case home = "Home"
        case carShows = "Car Shows"
        case cruiseNights = "Cruise Nights..."
        var id: String { rawValue }
    }
    
    private enum HomeImageOption: String, CaseIterable, Identifiable {
        case welcome = "Welcome" // Not shown in menu, only on app launch and Home being selected
        case favorites = "Car Show Favorites"
        case carShowInfo = "DFD Car Show Info"
        case carShow = "DFD Car Show Registration"
        case sponsors = "Sponsors"
        case carShowSponsors = "Car Show Sponsors"
        case gallery = "Gallery"
        case ourStory = "Our Story"
        case events = "Events"
        case contactUs = "Contact Us"
        case settings = "Settings"
        case donate = "Donate"
        var id: String { rawValue }
        
        var imageName: String? {
            switch self {
            case .welcome:
                return "HomeImage" // Home Page Image
            case .carShowInfo:
                return "CarShowImage"
            case .favorites, .carShowSponsors, .sponsors, .gallery, .carShow, .donate, .ourStory, .events, .contactUs, .settings:
                return nil // Will use WebView, EventsView, FavoritesView, or text instead
            }
        }
        
        var galleryURL: String? {
            switch self {
            case .gallery:
                return "https://www.drivefordana.org/mobileappgallery"
            default:
                return nil
            }
        }
        
        var webURL: String? {
            switch self {
            case .carShow:
                return "https://www.zeffy.com/en-US/ticketing/drive-for-dana-car-and-truck-show--2026"
            case .donate:
                return "https://www.zeffy.com/en-US/donation-form/78541d04-41af-47eb-ba42-033f70c53097"
            default:
                return nil
            }
        }
        
        var storyText: String? {
            switch self {
            case .ourStory:
                return """
                OUR STORY
                
                Dana Ryan suffered a near fatal drowning on July 9, 2018. Dana’s parents were told she suffered a traumatic brain injury from the drowning and the doctors gave her 3 weeks to live. Dana never gave up and kept fighting. We met Dana that September and immediately knew we had to help her. We were planning a car show and decided at that moment to create Drive for Dana, make the car show a fundraiser and donate all the money to her therapy. We had a very successful show and immediately began work on the next. Unfortunately, the pandemic delayed us a year.
                 
                During 2021, we created many goals for Drive for Dana. A few of those goals were growing our show, creating a 501(c)(3) nonprofit organization, expanding our reach to help other medically fragile children on Long Island and finding corporate sponsors who share our goal of helping Long Island children in need.
                ​
                In 2022, we continued to provide Dana with many of her much needed services and equipment.
                Drive for Dana also provided three additional families of medically fragile children with equipment to help support their children.
                In 2023, we continued to provide these services and we helped an additional 10 families throughout the year.  Drive For Dana had an amazing year thanks to all of our supporters and sponsors of our events.
                In 2024 we introduced our Winter Breakfast Fundraiser, it was a fantastic success and will now be an annual event.  We also partnered with Bahama Breeze of Lake Grove for a Top Chef event that was absolutely fantastic, we we chosen as the charity again and are so excited.  All of these events and our car show allowed us to continue Dana's treatments, help other children and families as well as do a holiday wish list for our kids. 2024 was a great year.
                See you soon at a Drive For Dana Event.
                 
                Dana, Jacob, Pennie, Emily, Carmelo, Jackson, Sophia, Lauren, Amina, Don, Kayla, Addie, Kaleb and the rest of our kids continue to fight and are making strides every day.
                """
            case .contactUs:
                return nil // Will use ContactUsView instead
            default:
                return nil
            }
        }
        
        var showInMenu: Bool {
            // Don't show donate, welcome, sponsors, and car show sponsors in menu dropdown
            self != .donate && self != .welcome && self != .sponsors && self != .carShowSponsors
        }
    }
    
    private enum LinkAction: String, CaseIterable, Identifiable {
        case menu = "Menu"
        case donate = "Donate"
        case registration = "Car Show"
        var id: String { rawValue }
        
        var url: URL? {
            switch self {
            case .menu:
                return nil // Menu is handled separately
            case .donate:
                return URL(string: "https://www.zeffy.com/en-US/donation-form/78541d04-41af-47eb-ba42-033f70c53097")
            case .registration:
                return URL(string: "https://www.zeffy.com/en-US/ticketing/drive-for-dana-car-and-truck-show--2026")
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Logo/Image at top
                Image("TopImage")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.top, -5)
                
                // Header
                HStack {
                    Text("Long Island Car Shows and Cruise Nights/Cars & Coffee")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 5)
                .padding(.bottom, 8)

                // Segmented picker for tab selection
                HStack(spacing: 0) {
                    ForEach(Selection.allCases) { option in
                        Button(action: {
                            // If tapping Home, always reset to welcome
                            if option == .home {
                                homeImageSelection = .welcome
                            }
                            selection = option
                        }) {
                            Text(option.rawValue)
                                .font(.subheadline)
                                .foregroundColor(selection == option ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                                .background(selection == option ? Color.accentColor : Color.clear)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(Color(UIColor.secondarySystemFill))
                .clipShape(Capsule())
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Content based on selection
                Group {
                    switch selection {
                    case .home:
                        // Home Tab with image selection menu
                        VStack(spacing: 0) {
                            // Segmented-style control with Menu, Sponsors, and Donate
                            HStack(spacing: 0) {
                                // Menu dropdown (first segment)
                                Menu {
                                    ForEach(HomeImageOption.allCases.filter { $0.showInMenu }) { option in
                                        Button(option.rawValue) {
                                            homeImageSelection = option
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("Menu")
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 10))
                                    }
                                    .font(.system(size: 13))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                                    .background(Color(UIColor.secondarySystemFill), in: Capsule())
                                }
                                .frame(maxWidth: .infinity)
                                
                                // Gap between Menu and Sponsors
                                Spacer().frame(width: 5)
                                
                                // Sponsors segment
                                Button(action: {
                                    homeImageSelection = .sponsors
                                }) {
                                    Text("Sponsors")
                                        .font(.system(size: 13))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 4)
                                        .background(Color(UIColor.secondarySystemFill), in: Capsule())
                                }
                                .frame(maxWidth: .infinity)
                                
                                // Gap between Sponsors and Donate
                                Spacer().frame(width: 5)
                                
                                // Donate segment
                                Button(action: {
                                    homeImageSelection = .donate
                                }) {
                                    Text(LinkAction.donate.rawValue)
                                        .font(.system(size: 13))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 4)
                                        .background(Color(UIColor.secondarySystemFill), in: Capsule())
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(2)
                            .background(Color(UIColor.tertiarySystemFill), in: Capsule())
                            .padding(.horizontal)
                            .padding(.top, 0)
                            
                            // Content under the menu - changes based on homeImageSelection
                            if let imageName = homeImageSelection.imageName {
                                // Show image for non-webview options
                                Image(imageName)
                                    .resizable()
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .animation(.easeInOut(duration: 0.3), value: homeImageSelection)
                            } else if homeImageSelection == .sponsors {
                                // Show SponsorsView for Official Sponsors
                                SponsorsView()
                                    .padding(.top, 5)
                                    .animation(.easeInOut(duration: 0.3), value: homeImageSelection)
                            } else if homeImageSelection == .carShowSponsors {
                                // Show CarShowSponsorsView for Car Show Sponsors
                                CarShowSponsorsView()
                                    .padding(.top, 5)
                                    .animation(.easeInOut(duration: 0.3), value: homeImageSelection)
                            } else if let galleryURL = homeImageSelection.galleryURL {
                                // Show WebView for Gallery images from URL
                                WebView(urlString: galleryURL)
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .animation(.easeInOut(duration: 0.3), value: homeImageSelection)
                            } else if let webURL = homeImageSelection.webURL {
                                // Show WebView for Car Show and Donate options
                                WebView(urlString: webURL)
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .animation(.easeInOut(duration: 0.3), value: homeImageSelection)
                            } else if homeImageSelection == .favorites {
                                // Show FavoritesView for Favorites option
                                FavoritesView()
                                    .padding(.top, 5)
                                    .animation(.easeInOut(duration: 0.3), value: homeImageSelection)
                            } else if homeImageSelection == .events {
                                // Show EventsView for Events option
                                EventsView()
                                    .padding(.top, 5)
                                    .animation(.easeInOut(duration: 0.3), value: homeImageSelection)
                            } else if homeImageSelection == .contactUs {
                                // Show ContactUsView for Contact Us option
                                ContactUsView()
                                    .padding(.top, 5)
                                    .animation(.easeInOut(duration: 0.3), value: homeImageSelection)
                            } else if homeImageSelection == .settings {
                                // Show SettingsView for Settings option
                                SettingsView()
                                    .padding(.top, 5)
                                    .animation(.easeInOut(duration: 0.3), value: homeImageSelection)
                            } else if let storyText = homeImageSelection.storyText {
                                // Show text for Our Story
                                ScrollView {
                                    Text(storyText)
                                        .font(.body)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal)
                                .padding(.top, 5)
                                .animation(.easeInOut(duration: 0.3), value: homeImageSelection)
                            }
                            
                            Spacer()
                        }
                        
                    case .carShows:
                        // Car Shows Tab with swipeable months
                        CarShowsView(monthIndex: $monthIndex)
                        
                    case .cruiseNights:
                        // Cruise Nights Tab with swipeable days
                        VStack(spacing: 8) {
                            HStack(spacing: 16) {
                                Button(action: {
                                    withAnimation {
                                        dayOfWeekIndex = (dayOfWeekIndex - 1 + daysOfWeek.count) % daysOfWeek.count
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                }
                                .buttonStyle(.bordered)

                                Text(daysOfWeek[dayOfWeekIndex])
                                    .font(.headline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.thinMaterial, in: Capsule())

                                Button(action: {
                                    withAnimation {
                                        dayOfWeekIndex = (dayOfWeekIndex + 1) % daysOfWeek.count
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.horizontal)
                            
                            // Header above cruise nights
                            //Text("Cruise Nights and Cars & Coffee for \(daysOfWeek[dayOfWeekIndex])")
                            Text("Cruise Nights and Cars & Coffee")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                                .padding(.bottom, 0)
                            
                            CruiseNightsView(dayOfWeekIndex: $dayOfWeekIndex)
                        }
                        .onAppear {
                            let currentDayNumber = Calendar.current.component(.weekday, from: Date())
                            dayOfWeekIndex = currentDayNumber - 1
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .background(Color(UIColor.systemGray6))
            .ignoresSafeArea(.container, edges: [.bottom])
            .task {
                // Ensure we start on Home tab on app launch
                if selection != .home {
                    selection = .home
                }
                
                // Preload all car shows and cruise nights data in background
                print("🚀 Starting preload of all data...")
                await DataManager.shared.preloadAllData()
                print("✅ Preload complete!")
            }
        }
    }
}

#Preview("ContentView Preview") {
    ContentView()
}


