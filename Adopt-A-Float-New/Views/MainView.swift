//
//  MainView.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 8/30/24.
//

import SwiftUI
import CoreData
import MapKit

// MARK: - CustomPolyline
/// Extends MKPolyline to include additional metadata.
class CustomPolyline: MKPolyline {
    var dateTime: Date?
    var instrumentName: String?
    
    /// Convenience initializer to set additional properties.
    /// - Parameters:
    ///   - coordinates: Array of CLLocationCoordinate2D points.
    ///   - count: Number of points.
    ///   - dateTime: Timestamp associated with the polyline.
    ///   - instrumentName: Name of the associated instrument.
    convenience init(coordinates: [CLLocationCoordinate2D], count: Int, dateTime: Date?, instrumentName: String?) {
        self.init(coordinates: coordinates, count: count)
        self.dateTime = dateTime
        self.instrumentName = instrumentName
    }
}

// MARK: - CustomSmoothPolyline
/// Provides a method to smooth polylines by inserting midpoints.
class CustomSmoothPolyline: CustomPolyline {
    
    /// Creates a smoothed path by inserting midpoints between coordinates.
    /// - Parameter coordinates: Array of CLLocationCoordinate2D points.
    /// - Returns: Array of smoothed CLLocationCoordinate2D points.
    static func createSmoothPath(coordinates: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        guard coordinates.count >= 2 else { return coordinates }
        
        var smoothCoordinates: [CLLocationCoordinate2D] = []
        
        for i in 1..<coordinates.count {
            let prevPoint = coordinates[i - 1]
            let currentPoint = coordinates[i]
            
            // Calculate midpoint for smoothing
            let midPoint = CLLocationCoordinate2D(
                latitude: (prevPoint.latitude + currentPoint.latitude) / 2,
                longitude: (prevPoint.longitude + currentPoint.longitude) / 2
            )
            
            smoothCoordinates.append(prevPoint)
            smoothCoordinates.append(midPoint) // Insert midpoint
        }
        
        smoothCoordinates.append(coordinates.last!)
        
        return smoothCoordinates
    }
}

// MARK: - IdentifiablePointAnnotation
/// Represents a map annotation with identifiable properties.
struct IdentifiablePointAnnotation: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let dateTime: Date
    let instrument: Instrument?
    
    // Equatable conformance to compare annotations
    static func == (lhs: IdentifiablePointAnnotation, rhs: IdentifiablePointAnnotation) -> Bool {
        return lhs.id == rhs.id &&
            lhs.coordinate.latitude == rhs.coordinate.latitude &&
            lhs.coordinate.longitude == rhs.coordinate.longitude &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.dateTime == rhs.dateTime &&
            lhs.instrument?.name == rhs.instrument?.name
    }
}

// MARK: - MainView
/// The main view displaying the map with buoy annotations and controls.
struct MainView: View {
    @Binding var selectedInstrument: Instrument?
    @Binding var isAllInstrumentsSelected: Bool
    @Binding var showMainView: Bool  // Controls navigation
    
    @State private var polylines: [CustomPolyline] = []
    @Environment(\.managedObjectContext) private var viewContext
    @State private var instruments: [Instrument] = []
    @State private var onMarkers: [IdentifiablePointAnnotation] = []
    @State private var is3D: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var isPlaying: Bool = false
    @State private var playbackTimer: Timer? = nil
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )
    
    @State private var menuLabel: String = "Select All"
    
    var body: some View {
        ZStack {
            // Map view displaying annotations and polylines
            MapView(
                region: $region,
                is3D: $is3D,
                annotations: onMarkers,
                polylines: polylines,
                selectedDate: selectedDate,
                instrument: selectedInstrument
            )
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                loadInstruments()
                showMostRecentLocationsForAllInstruments()
                menuLabel = "Select All"
            }
            
            VStack {
                // Top Controls: Menu and Buttons
                HStack {
                    Menu {
                        // Back button to navigate away
                        Button("Back", action: {
                            showMainView = false
                        })
                        
                        // Select All instruments
                        Button("Select All", action: {
                            showMostRecentLocationsForAllInstruments()
                            isAllInstrumentsSelected = true
                            menuLabel = "Select All"
                        })
                        
                        // Region A Instruments
                        Section(header: Text("Region A")) {
                            ForEach(instruments.prefix(24), id: \.self) { instrument in
                                Button(instrument.name) {
                                    selectInstrument(instrument)
                                }
                            }
                        }
                        
                        // Region B Instruments
                        Section(header: Text("Region B")) {
                            ForEach(instruments.suffix(24), id: \.self) { instrument in
                                Button(instrument.name) {
                                    selectInstrument(instrument)
                                }
                            }
                        }
                        
                    } label: {
                        Label(menuLabel, systemImage: "chevron.down")
                            .padding(10)
                            .background(Color(.systemBackground).opacity(0.8))
                            .cornerRadius(8)
                    }
                    .frame(width: 150)
                    .padding(.leading, 5)
                    
                    Spacer()
                    
                    // Toggle 3D view and Reset button
                    HStack(spacing: 10) {
                        Button(action: { is3D.toggle() }) {
                            Image(systemName: is3D ? "map" : "globe")
                                .font(.system(size: 20))
                                .padding(8)
                                .background(Color(.systemBackground).opacity(0.8))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            if let selectedInstrument = selectedInstrument {
                                clearOnMarkers()
                                setupInstrument(selectedInstrument)
                                updateSelectedDateToLatest()
                            }
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 20))
                                .padding(8)
                                .background(Color(.systemBackground).opacity(0.8))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.trailing, 20)
                }
                .padding([.leading, .trailing], 10)
                .padding(.top, 5)
                
                Spacer()
                
                // Playback Controls for Selected Instrument
                if !isAllInstrumentsSelected, let selectedInstrument = selectedInstrument {
                    let dates = selectedInstrument.floatData.map { $0.dateTime }
                    if let minDate = dates.min(), let maxDate = dates.max() {
                        VStack {
                            HStack {
                                // Play/Pause Button
                                Button(action: {
                                    isPlaying.toggle()
                                    if isPlaying {
                                        startPlayback(minDate: minDate, maxDate: maxDate)
                                    } else {
                                        stopPlayback()
                                    }
                                }) {
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .font(.title2)
                                        .padding()
                                        .background(Color(.systemBackground).opacity(0.8))
                                        .clipShape(Circle())
                                }
                                
                                // Date Slider
                                Slider(
                                    value: Binding(
                                        get: { selectedDate.timeIntervalSince1970 },
                                        set: { newValue in
                                            selectedDate = Date(timeIntervalSince1970: newValue)
                                            updateMarkersForSelectedDate()
                                        }
                                    ),
                                    in: minDate.timeIntervalSince1970...maxDate.timeIntervalSince1970
                                )
                                .accentColor(.blue)
                            }
                            .padding(.horizontal)
                            
                            // Display Selected Date
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
        
    // MARK: - Playback Controls
    
    /// Starts the playback timer to animate date changes.
    /// - Parameters:
    ///   - minDate: The earliest date in the data.
    ///   - maxDate: The latest date in the data.
    private func startPlayback(minDate: Date, maxDate: Date) {
        selectedDate = minDate
        let totalDuration: TimeInterval = 30.0
        let dateRange = maxDate.timeIntervalSince(minDate)
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            DispatchQueue.main.async {
                let step = dateRange / (totalDuration / 0.2)
                
                selectedDate += step
                
                if selectedDate >= maxDate {
                    stopPlayback()
                }
                
                updateMarkersForSelectedDate()
            }
        }
    }
    
    /// Stops the playback timer.
    private func stopPlayback() {
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    // MARK: - Instrument Management
    
    /// Loads instruments from the data source.
    private func loadInstruments() {
        instruments = DataUtility.createInstruments()
        if let instrument = instruments.first {
            setupInstrument(instrument)
            updateSelectedDateToLatest()
        }
    }
    
    /// Sets up the selected instrument by clearing markers and updating data.
    /// - Parameter instrument: The instrument to set up.
    private func setupInstrument(_ instrument: Instrument) {
        clearOnMarkers()
        polylines.removeAll()
        updateMarkersForSelectedDate()
    }
    
    /// Selects an instrument and updates the view accordingly.
    /// - Parameter instrument: The instrument to select.
    private func selectInstrument(_ instrument: Instrument) {
        selectedInstrument = instrument
        setupInstrument(instrument)
        updateSelectedDateToLatest()
        isAllInstrumentsSelected = false
        menuLabel = instrument.name
    }
    
    /// Shows the most recent locations for all instruments.
    private func showMostRecentLocationsForAllInstruments() {
        clearOnMarkers()
        polylines.removeAll()
        
        var mostRecentMarkers: [IdentifiablePointAnnotation] = []
        
        for instrument in instruments {
            if let mostRecentData = instrument.floatData.max(by: { $0.dateTime < $1.dateTime }) {
                let marker = IdentifiablePointAnnotation(
                    coordinate: CLLocationCoordinate2D(latitude: mostRecentData.latitude, longitude: mostRecentData.longitude),
                    title: instrument.name,
                    subtitle: DateFormatter.localizedString(from: mostRecentData.dateTime, dateStyle: .medium, timeStyle: .short),
                    dateTime: mostRecentData.dateTime,
                    instrument: instrument
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
    
    /// Updates the selected date to the latest available data point.
    private func updateSelectedDateToLatest() {
        if let selectedInstrument = selectedInstrument,
           let latestDate = selectedInstrument.floatData.map({ $0.dateTime }).max() {
            selectedDate = latestDate
            updateMarkersForSelectedDate()
        }
    }
    
    /// Clears all current markers from the map.
    private func clearOnMarkers() {
        onMarkers.removeAll()
    }
    
    // MARK: - Marker and Polyline Updates
    
    /// Updates markers based on the selected date.
    private func updateMarkersForSelectedDate() {
        guard let selectedInstrument = selectedInstrument else { return }
        
        // Filter data points up to the selected date
        let filteredData = selectedInstrument.floatData.filter { $0.dateTime <= selectedDate }
        let sortedData = filteredData.sorted { $0.dateTime < $1.dateTime }
        
        // Create new markers from filtered data
        let newMarkers = sortedData.map { dataPoint in
            IdentifiablePointAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: dataPoint.latitude, longitude: dataPoint.longitude),
                title: selectedInstrument.name,
                subtitle: DateFormatter.localizedString(from: dataPoint.dateTime, dateStyle: .medium, timeStyle: .short),
                dateTime: dataPoint.dateTime,
                instrument: selectedInstrument
            )
        }
        
        if newMarkers != onMarkers {
            onMarkers = newMarkers
        }
        
        // Update polylines based on sorted data
        updatePolylines(with: sortedData)
        
        // Center the map on the latest marker
        if let lastCoord = onMarkers.last?.coordinate {
            region = MKCoordinateRegion(center: lastCoord, span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0))
        }
    }
    
    /// Updates polylines based on the provided data points.
    /// - Parameter dataPoints: Array of FloatData points.
    private func updatePolylines(with dataPoints: [FloatData]) {
        polylines.removeAll()
        guard dataPoints.count > 1 else { return }
        
        // Adjust coordinates for meridian crossing
        let adjustedCoordinates = adjustForMeridianCrossing(dataPoints.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        })
        
        // Create a smooth path and add as a polyline
        let smoothCoords = CustomSmoothPolyline.createSmoothPath(coordinates: adjustedCoordinates)
        let polyline = CustomPolyline(
            coordinates: smoothCoords,
            count: smoothCoords.count,
            dateTime: dataPoints.last?.dateTime,
            instrumentName: selectedInstrument?.name
        )
        polylines.append(polyline)
    }
    
    /// Adjusts coordinates to handle crossing the International Date Line.
    /// - Parameter coordinates: Array of CLLocationCoordinate2D points.
    /// - Returns: Array of adjusted CLLocationCoordinate2D points.
    private func adjustForMeridianCrossing(_ coordinates: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        var adjustedCoords = [CLLocationCoordinate2D]()
        
        for i in 0..<coordinates.count {
            let currentPoint = coordinates[i]
            if i > 0 {
                let previousPoint = adjustedCoords[i - 1]
                let longitudeDifference = abs(currentPoint.longitude - previousPoint.longitude)
                
                // Adjust longitude if crossing the 180th meridian
                if longitudeDifference > 180 {
                    if currentPoint.longitude > previousPoint.longitude {
                        adjustedCoords.append(CLLocationCoordinate2D(latitude: currentPoint.latitude, longitude: currentPoint.longitude - 360))
                    } else {
                        adjustedCoords.append(CLLocationCoordinate2D(latitude: currentPoint.latitude, longitude: currentPoint.longitude + 360))
                    }
                } else {
                    adjustedCoords.append(currentPoint)
                }
            } else {
                adjustedCoords.append(currentPoint)
            }
        }
        return adjustedCoords
    }
}

