//
//  ContentView.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 8/30/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoading = false
    @State private var downloadProgress: CGFloat = 0.0
    @State private var dataDownloaded = false
    @State private var showMainView = false  // State for showing MainView
    
    var body: some View {
        ZStack {
            // Updated Ocean Background
            OceanBackground()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                // Buoy Logo at the top
                Spacer()
                Image("buoyLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 80)
                
                // Loading progress bar if downloading
                if isLoading {
                    ProgressBar(progress: downloadProgress)
                        .frame(height: 10)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                }

                // Track Buoys button, disabled if still downloading
                Button(action: {
                    if dataDownloaded {
                        showMainView = true
                    }
                }) {
                    Text("Track Buoys")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(dataDownloaded ? Color.white : Color.gray.opacity(0.5))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
                .padding(.horizontal, 40)
                .disabled(!dataDownloaded)  // Disable until data is downloaded
                
                Spacer()
            }
            
            // Present MainView when the button is clicked
            if showMainView {
                MainView()
                    .transition(.move(edge: .bottom))
            }
        }
        .onAppear(perform: startDownload)  // Automatically start downloading when view appears
    }

    // Simulate the download process
    private func startDownload() {
        isLoading = true
        dataDownloaded = false
        downloadProgress = 0.0
        
        // Simulate download by incrementing progress
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            downloadProgress += 0.1
            if downloadProgress >= 1.0 {
                isLoading = false
                dataDownloaded = true
                timer.invalidate()
            }
        }
    }
}


// Custom progress bar view
struct ProgressBar: View {
    var progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Rectangle()
                    .frame(width: min(geometry.size.width * progress, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color.blue)
                    .animation(.linear(duration: 0.2))
            }
            .cornerRadius(45.0)
        }
    }
}

// Custom ocean background with gradient and horizon effect
struct OceanBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sky gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .center
                )
                
                // Ocean gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7), Color.blue.opacity(0.4)]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Gentle ocean waves using blur for a subtle effect
                Ellipse()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: geometry.size.width * 1.5, height: 100)
                    .offset(x: -geometry.size.width * 0.3, y: geometry.size.height * 0.65)
                    .blur(radius: 10)
                
                Ellipse()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: geometry.size.width * 1.2, height: 80)
                    .offset(x: geometry.size.width * 0.2, y: geometry.size.height * 0.7)
                    .blur(radius: 20)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
