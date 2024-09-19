//
//  ContentView.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 8/30/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: MainView()) {
                    Text("Go to Main View")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                NavigationLink(destination: DetailView()) {
                    Text("Go to Detail View")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationBarTitle("Main View")
        }
    }
}

struct DetailView: View {
    var body: some View {
        Text("Detail View")
    }
}

