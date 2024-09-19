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
    let dateTime: Date // Ensure this is included for the timeline slider

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
        span: MKCoordinateSpan(latitudeDelta: 100.0, longitudeDelta: 100.0)
    )

    var body: some View {
        ZStack {
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
                // Timeline Slider
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
                        .padding(.top, 40)
                    }
                }

                Spacer()

                // Instrument Picker
                if !instruments.isEmpty {
                    Picker("Select an Instrument", selection: $selectedInstrument) {
                        ForEach(instruments, id: \.self) { instrument in
                            Text(instrument.name).tag(instrument as Instrument?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                    .background(Color(.systemBackground).opacity(0.8))
                    .cornerRadius(10)
                    .padding(.bottom, 8)
                    .onChange(of: selectedInstrument) { oldInstrument, newInstrument in
                        // Use oldInstrument and newInstrument as needed
                        if let newInstrument = newInstrument {
                            setupInstrument(newInstrument)
                            updateSelectedDateToLatest()
                        }
                    }
                }

                // Control Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        if let selectedInstrument = selectedInstrument {
                            clearOnMarkers()
                            setupInstrument(selectedInstrument)
                            updateSelectedDateToLatest()
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title)
                            .padding()
                            .background(Color(.systemBackground).opacity(0.8))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Reset View")

                    Button(action: {
                        is3D.toggle()
                    }) {
                        Image(systemName: is3D ? "map" : "globe")
                            .font(.title)
                            .padding()
                            .background(Color(.systemBackground).opacity(0.8))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(is3D ? "2D View" : "3D View")
                }
                .padding(.bottom, 40)
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
        updateMarkersForSelectedDate()
    }

    private func updateMarkersForSelectedDate() {
        guard let selectedInstrument = selectedInstrument else { return }

        // Filter data points up to the selected date
        let filteredData = selectedInstrument.floatData.filter { $0.dateTime <= selectedDate }

        // Sort data by date (if not already sorted)
        let sortedData = filteredData.sorted { $0.dateTime < $1.dateTime }

        // Map to new annotations
        let newMarkers = sortedData.map { dataPoint in
            IdentifiablePointAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: dataPoint.latitude, longitude: dataPoint.longitude),
                title: selectedInstrument.name,
                subtitle: DateFormatter.localizedString(from: dataPoint.dateTime, dateStyle: .medium, timeStyle: .short),
                dateTime: dataPoint.dateTime
            )
        }

        // Only update if the markers have changed
        if newMarkers != onMarkers {
            onMarkers = newMarkers
        }

        // Update polylines
        updatePolylines(with: sortedData)

        // Update region only if needed
        if let lastCoord = onMarkers.last?.coordinate {
            if region.center.latitude != lastCoord.latitude || region.center.longitude != lastCoord.longitude {
                region = MKCoordinateRegion(center: lastCoord, span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
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
