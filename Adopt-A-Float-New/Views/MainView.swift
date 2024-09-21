//
//  MainView.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 8/30/24.
//

import SwiftUI
import CoreData
import MapKit

struct IdentifiablePointAnnotation: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let dateTime: Date

    static func == (lhs: IdentifiablePointAnnotation, rhs: IdentifiablePointAnnotation) -> Bool {
        return lhs.id == rhs.id &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude &&
               lhs.title == rhs.title &&
               lhs.subtitle == rhs.subtitle &&
               lhs.dateTime == rhs.dateTime
    }
}

struct MainView: View {
    @State private var polylines: [CustomPolyline] = []
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedInstrument: Instrument?
    @State private var instruments: [Instrument] = []
    @State private var onMarkers: [IdentifiablePointAnnotation] = []
    @State private var is3D: Bool = false
    @State private var selectedDate: Date = Date() // For timeline slider

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 20.0, longitudeDelta: 20.0) // Medium zoom level
    )

    var body: some View {
        ZStack {
            // Map view with the adjusted region zoom level
            MapView(region: $region, is3D: $is3D, annotations: onMarkers, polylines: polylines, selectedDate: selectedDate, instrument: selectedInstrument)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    loadInstruments()
                    if let firstInstrument = instruments.first {
                        selectedInstrument = firstInstrument
                        setupInstrument(firstInstrument)
                        updateSelectedDateToLatest()
                    }
                }

            VStack {
                HStack {
                    // Top-left instrument picker dropdown
                    Menu {
                        Button("Select All", action: {
                            // Display the most recent date and location of each instrument
                            showMostRecentLocationsForAllInstruments()
                        })
                        ForEach(instruments, id: \.self) { instrument in
                            Button(instrument.name) {
                                selectedInstrument = instrument
                                setupInstrument(instrument)
                                updateSelectedDateToLatest()
                            }
                        }
                    } label: {
                        Label("Show:", systemImage: "chevron.down")
                            .padding()
                            .background(Color(.systemBackground).opacity(0.8))
                            .cornerRadius(8)
                    }
                    .frame(width: 150) // Controls the width of the dropdown
                    .alignmentGuide(.leading) { d in d[.leading] } // Align to the top-left corner

                    Spacer()

                    // Top-right corner icons: Globe and Redo buttons
                    HStack(spacing: 10) {
                        Button(action: {
                            is3D.toggle()
                        }) {
                            Image(systemName: is3D ? "map" : "globe")
                                .font(.system(size: 20)) // Smaller icon
                                .padding(8)
                                .background(Color(.systemBackground).opacity(0.8))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel(is3D ? "2D View" : "3D View")

                        Button(action: {
                            if let selectedInstrument = selectedInstrument {
                                clearOnMarkers()
                                setupInstrument(selectedInstrument)
                                updateSelectedDateToLatest()
                            }
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 20)) // Smaller icon
                                .padding(8)
                                .background(Color(.systemBackground).opacity(0.8))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Reset View")
                    }
                    .alignmentGuide(.trailing) { d in d[.trailing] } // Align to the top-right corner
                }
                .padding(.horizontal, 20) // Adjust horizontal padding
                .padding(.top, 50)        // Adjust top padding for proper positioning

                Spacer()

                // Timeline slider at the bottom of the screen
                if let selectedInstrument = selectedInstrument {
                    let dates = selectedInstrument.floatData.map { $0.dateTime }
                    if let minDate = dates.min(), let maxDate = dates.max() {
                        VStack {
                            Slider(
                                value: Binding(
                                    get: {
                                        selectedDate.timeIntervalSince1970
                                    },
                                    set: { newValue in
                                        selectedDate = Date(timeIntervalSince1970: newValue)
                                        updateMarkersForSelectedDate()
                                    }
                                ),
                                in: minDate.timeIntervalSince1970...maxDate.timeIntervalSince1970
                            )
                            .padding(.horizontal)
                            .accentColor(.blue)

                            Text("Date: \(DateFormatter.localizedString(from: selectedDate, dateStyle: .medium, timeStyle: .short))")
                                .padding(5)
                                .background(Color(.systemBackground).opacity(0.8))
                                .cornerRadius(10)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }

    private func loadInstruments() {
        instruments = DataUtility.createInstruments()
        print("Instruments loaded: \(instruments.count)")
        if let instrument = instruments.first {
            print("First instrument has \(instrument.floatData.count) data points")
        }
    }

    private func setupInstrument(_ instrument: Instrument) {
        clearOnMarkers()
        polylines.removeAll()  // Clear previous polylines
        updateMarkersForSelectedDate()
    }

    private func updateMarkersForSelectedDate() {
        guard let selectedInstrument = selectedInstrument else { return }

        let filteredData = selectedInstrument.floatData.filter { $0.dateTime <= selectedDate }
        let sortedData = filteredData.sorted { $0.dateTime < $1.dateTime }

        let newMarkers = sortedData.map { dataPoint in
            IdentifiablePointAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: dataPoint.latitude, longitude: dataPoint.longitude),
                title: selectedInstrument.name,
                subtitle: DateFormatter.localizedString(from: dataPoint.dateTime, dateStyle: .medium, timeStyle: .short),
                dateTime: dataPoint.dateTime
            )
        }

        if newMarkers != onMarkers {
            onMarkers = newMarkers
        }

        updatePolylines(with: sortedData)

        if let lastCoord = onMarkers.last?.coordinate {
            if region.center.latitude != lastCoord.latitude || region.center.longitude != lastCoord.longitude {
                region = MKCoordinateRegion(center: lastCoord, span: MKCoordinateSpan(latitudeDelta: 20.0, longitudeDelta: 20.0)) // Medium zoom level
            }
        }
    }

    private func updatePolylines(with dataPoints: [FloatData]) {
        polylines.removeAll()

        for i in 0..<(dataPoints.count - 1) {
            let coords = [
                CLLocationCoordinate2D(latitude: dataPoints[i].latitude, longitude: dataPoints[i].longitude),
                CLLocationCoordinate2D(latitude: dataPoints[i+1].latitude, longitude: dataPoints[i+1].longitude)
            ]
            let polyline = CustomPolyline(coordinates: coords, count: coords.count, dateTime: dataPoints[i+1].dateTime)
            polylines.append(polyline)
        }
    }

    private func showMostRecentLocationsForAllInstruments() {
        clearOnMarkers()
        polylines.removeAll()  // Clear previous polylines before showing recent locations

        var mostRecentMarkers: [IdentifiablePointAnnotation] = []

        for instrument in instruments {
            if let mostRecentData = instrument.floatData.max(by: { $0.dateTime < $1.dateTime }) {
                let marker = IdentifiablePointAnnotation(
                    coordinate: CLLocationCoordinate2D(latitude: mostRecentData.latitude, longitude: mostRecentData.longitude),
                    title: instrument.name,
                    subtitle: DateFormatter.localizedString(from: mostRecentData.dateTime, dateStyle: .medium, timeStyle: .short),
                    dateTime: mostRecentData.dateTime
                )
                mostRecentMarkers.append(marker)
            }
        }

        if mostRecentMarkers != onMarkers {
            onMarkers = mostRecentMarkers
        }

        if let lastCoord = mostRecentMarkers.last?.coordinate {
            region = MKCoordinateRegion(center: lastCoord, span: MKCoordinateSpan(latitudeDelta: 20.0, longitudeDelta: 20.0))
        }
    }


    private func updateSelectedDateToLatest() {
        if let selectedInstrument = selectedInstrument,
           let latestDate = selectedInstrument.floatData.map({ $0.dateTime }).max() {
            selectedDate = latestDate
            updateMarkersForSelectedDate()
        }
    }

    private func clearOnMarkers() {
        onMarkers.removeAll()
    }
}

class CustomPolyline: MKPolyline {
    var dateTime: Date?

    convenience init(coordinates: [CLLocationCoordinate2D], count: Int, dateTime: Date?) {
        self.init(coordinates: coordinates, count: count)
        self.dateTime = dateTime
    }
}

#Preview {
    MainView()
}
