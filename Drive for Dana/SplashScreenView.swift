
//
//  SplashScreenView.swift
//  Drive for Dana
//
//  Created by Donald Mandra on 3/5/26.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                // Solid light blue background
                Color(hue: 0.55, saturation: 0.3, brightness: 0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: 50)
                    
                    // Animated logo
                    Image("TopImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 1.0), value: isAnimating)
                    
                    Text("Long Island Car Shows & Cruise Nights")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 1.0).delay(0.5), value: isAnimating)
                    
                    Spacer()
                }
            }
            .onAppear {
                isAnimating = true
                
                // Transition to main content after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
