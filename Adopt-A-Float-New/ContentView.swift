//
 //  ContentView.swift
 //  Adopt-A-Float-New
 //
 //  Created by Tenzing Sherpa on 8/30/24.
 //
 
import SwiftUI

// MARK: - ContentView
/// The main view of the Adopt-A-Float-New application, handling the launch screen, main navigation, and user interactions.
struct ContentView: View {
    // MARK: - State Variables
    
    /// Controls the visibility of the launch screen.
    @State private var showLaunchScreen = true
    
    /// Controls the visibility of the main view.
    @State private var showMainView = false
    
    /// Holds the currently selected instrument.
    @State private var selectedInstrument: Instrument?
    
    /// Indicates whether all instruments are selected.
    @State private var isAllInstrumentsSelected = false
    
    /// Controls the visibility of the loading pop-up.
    @State private var showLoadingPopup = false

    // MARK: - Body
    var body: some View {
        // Conditional rendering based on the state of showLaunchScreen
        if showLaunchScreen {
            // Display the launch screen with a fade-in transition
            LaunchView()
                .transition(.opacity)
                .onAppear {
                    // After 3 seconds, hide the launch screen with animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showLaunchScreen = false
                        }
                    }
                }
        } else {
            // If not showing the launch screen, decide between showing MainView or the initial navigation view
            if showMainView {
                // Display the MainView with bindings to selectedInstrument, isAllInstrumentsSelected, and showMainView
                MainView(
                    selectedInstrument: $selectedInstrument,
                    isAllInstrumentsSelected: $isAllInstrumentsSelected,
                    showMainView: $showMainView
                )
                .transition(.move(edge: .bottom)) // Transition animation from the bottom
            } else {
                // Initial navigation view with ocean-themed background and navigation options
                NavigationView {
                    ZStack {
                        // Custom ocean-themed background
                        OceanBackground()
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 40) {
                            Spacer()
                            
                            // App Name with custom font and shadow for visual appeal
                            Text("Adopt-A-Float")
                                .font(.custom("AvenirNext-Bold", size: 32))  // Ensure "AvenirNext-Bold" is added to your project fonts
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                            
                            // Buoy launch screen image
                            Image("buoylaunchscreen") // Ensure "buoylaunchscreen" image is added to your asset catalog
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .padding(.vertical, 20)
                            
                            // Stack containing "Track Buoys" and "About" buttons
                            VStack(spacing: 20) {
                                // "Track Buoys" Button
                                Button(action: {
                                    // Trigger navigation to the main view with animation
                                    withAnimation {
                                        showMainView = true
                                    }
                                }) {
                                    Text("Track Buoys")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                }
                                .padding(.horizontal, 40)
                                .onLongPressGesture(minimumDuration: 3.0) {
                                    // Show the loading pop-up when the button is pressed for 3 seconds
                                    showLoadingPopup = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        // Simulate loading time and then navigate to the main view
                                        withAnimation {
                                            showMainView = true
                                            showLoadingPopup = false
                                        }
                                    }
                                }

                                // "About" Navigation Link
                                NavigationLink(destination: AboutView()) {
                                    Text("About")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                }
                                .padding(.horizontal, 40)
                            }
                            
                            Spacer()
                            
                            // Custom wave animation at the bottom of the screen
                            WaveAnimationView()
                                .frame(height: 150) // Ensure WaveAnimationView is defined elsewhere in your project
                        }

                        // Overlay for the loading pop-up
                        if showLoadingPopup {
                            LoadingPopupView()
                        }
                    }
                    .navigationBarHidden(true) // Hide the navigation bar for a cleaner look
                }
            }
        }
    }
    
    // MARK: - LoadingPopupView
    /// A pop-up view that displays a loading message with a progress spinner.
    struct LoadingPopupView: View {
        var body: some View {
            VStack(spacing: 20) {
                Text("Loading Map...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                ProgressView()  // Circular loading spinner
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5) // Increase the size of the spinner
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.4))  // Dim the background behind the pop-up
            .edgesIgnoringSafeArea(.all) // Extend the pop-up to cover the entire screen
        }
    }
    
    // MARK: - OceanBackground
    /// A custom background view that simulates an ocean with gradients and wave effects.
    struct OceanBackground: View {
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    // Sky gradient transitioning from light to darker blue
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)]),
                        startPoint: .top,
                        endPoint: .center
                    )
                    
                    // Ocean gradient transitioning from deep blue to lighter shades
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7), Color.blue.opacity(0.4)]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    
                    // First wave layer with a blur effect for subtlety
                    Ellipse()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: geometry.size.width * 1.5, height: 100)
                        .offset(x: -geometry.size.width * 0.3, y: geometry.size.height * 0.65)
                        .blur(radius: 10)
                    
                    // Second wave layer with a stronger blur effect
                    Ellipse()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: geometry.size.width * 1.2, height: 80)
                        .offset(x: geometry.size.width * 0.2, y: geometry.size.height * 0.7)
                        .blur(radius: 20)
                }
            }
        }
    }
    
    // MARK: - Previews
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
