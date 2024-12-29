//
//  AboutView.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 10/14/24.
//

import SwiftUI

// MARK: - AboutView
/// A view that displays information about the EarthScope-Oceans project and the team members.
struct AboutView: View {
    @Environment(\.colorScheme) var colorScheme  // Detects light or dark mode
    
    var body: some View {
        ZStack {
            // Background gradient that adjusts based on the current color scheme
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark ? [Color.black, Color.blue.opacity(0.7)] : [Color.blue.opacity(0.3), Color.cyan.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Section Title: Learn About Us
                    Text("Learn About Us")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.top, 40)
                        .padding(.horizontal, 20)
                    
                    // About EarthScope-Oceans Card
                    AboutCard(title: "About EarthScope-Oceans") {
                        Text("""
EarthScope-Oceans is an international academic consortium founded in 2016. It coordinates efforts to create a global network of sensors that monitor the Earth from within the oceanic environment. EarthScope-Oceans shepherds national projects into the international arena where globally relevant, applicable, and mutually agreed-upon decisions can be made on instrument development, science objectives, data management, and outreach.
""")
                    }
                    
                    // Section Title: Meet the Team
                    Text("Meet the Team")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.horizontal, 20)
                    
                    // Professor Simons' Bio Card
                    AboutCard {
                        HStack(alignment: .top, spacing: 15) {
                            Image("Simons")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                .clipped()
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Professor Frederik Simons")
                                    .font(.headline)
                                
                                Text("""
Professor Frederik Simons is a geophysicist at Princeton University. His research focuses on using seismic waves to probe the Earth's interior. As one of the founders of EarthScope-Oceans, Professor Simons has played a key role in advancing seafloor seismology through innovative instruments like MERMAID.
""")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Tenzing Sherpa's Bio Card
                    AboutCard {
                        HStack(alignment: .top, spacing: 15) {
                            Image("Tenzing")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.green, lineWidth: 2))
                                .clipped()
        
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Tenzing Sherpa")
                                    .font(.headline)
        
                                Text("""
Tenzing Sherpa is the lead developer of the Adopt-A-Float app, leveraging his background in software development and military service to create tools for ocean researchers. As a U.S. Air Force Veteran, Tenzing is currently an undergraduate at Princeton University. He is studying Computer Science and is passionate about building creative solutions.
""")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
        
                    // Data Release Policies Card
                    AboutCard(title: "Data Release Policies") {
                        Text("""
Seismologists have mapped out elastic wave speeds of the Earth's interior in recent decades. However, earthquake sources mostly lie on plate boundaries, and receivers are primarily on dry land, leaving large volumes inside the Earth unsampled.
""")
                    }
                }
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitle("About", displayMode: .inline)
    }
}

// MARK: - AboutCard
/// A reusable card view for displaying sections with optional titles.
struct AboutCard<Content: View>: View {
    var title: String?
    let content: Content
    @Environment(\.colorScheme) var colorScheme  // Detects light or dark mode
    
    // Initializes the AboutCard with an optional title and content.
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Display the title if provided
            if let title = title {
                Text(title)
                    .font(.headline)
                    .padding(.bottom, 5)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            // Content of the card
            content
        }
        .padding(20)
        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - AboutView_Previews
/// Preview for AboutView in both light and dark modes.
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AboutView()
                .preferredColorScheme(.light)
            
            AboutView()
                .preferredColorScheme(.dark)
        }
    }
}
