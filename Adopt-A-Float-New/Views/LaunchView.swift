//
//  LaunchView.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 10/14/24.
//

import SwiftUI

// MARK: - LaunchView
/// A SwiftUI view that serves as the launch screen for the "Adopt-A-Float" application.
/// It features a background gradient, app title, a central image, and a wave animation at the bottom.
struct LaunchView: View {
    var body: some View {
        ZStack {
            // MARK: - Background Gradient
            // Creates a vertical gradient from a semi-transparent blue to cyan to represent sky and water.
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all) // Extends the gradient to cover the entire screen, ignoring safe areas.
            
            VStack {
                // MARK: - App Title
                // Displays the app's name with styling at the top of the screen.
                Text("Adopt-A-Float")
                    .font(.largeTitle) // Sets the font size to large.
                    .fontWeight(.bold) // Makes the text bold.
                    .foregroundColor(.white) // Sets the text color to white for contrast against the background.
                    .padding(.top, 50) // Adds padding of 50 points from the top.
                
                Spacer() // Adds flexible space to push subsequent views towards the center.
    
                // MARK: - Central Image
                // Displays the "buoylaunchscreen" image in the center of the screen.
                Image("buoylaunchscreen")
                    .resizable() // Allows the image to be resized.
                    .scaledToFit() // Scales the image to fit within its frame while maintaining aspect ratio.
                    .frame(width: 200, height: 200) // Sets the width and height of the image to 200 points each.
                    .padding(.vertical, 50)  // Adds vertical padding of 50 points above and below the image.
                
                Spacer() // Adds flexible space to push the wave animation towards the bottom.
    
                // MARK: - Wave Animation
                // Integrates the reusable wave animation component at the bottom of the launch screen.
                WaveAnimationView() // Utilizes the previously defined WaveAnimationView for animated wave effects.
                
                Spacer() // Adds flexible space below the wave animation.
            }
        }
    }
}

// MARK: - LaunchView_Previews
/// Provides a preview of the LaunchView for SwiftUI's canvas.
struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
