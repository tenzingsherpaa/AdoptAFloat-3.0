//
//  MapView.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 8/30/24.
//

import SwiftUI
import MapKit

// MARK: - MapView
/// A SwiftUI wrapper for UIKit's MKMapView, displaying buoy locations and routes.
struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion       // Current map region
    @Binding var is3D: Bool                       // Toggle for 3D map view
    var annotations: [IdentifiablePointAnnotation] // Buoy annotations
    var polylines: [CustomPolyline]               // Routes or paths
    var selectedDate: Date                        // Selected date for data filtering
    var instrument: Instrument?                   // Selected instrument details

    // Coordinator to handle MKMapViewDelegate methods
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var is3D: Bool

        init(parent: MapView) {
            self.parent = parent
            self.is3D = parent.is3D
            super.init()
        }

        // Renderer for map overlays (e.g., polylines)
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? CustomPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }

        // View for map annotations (buoys)
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let mkAnnotation = annotation as? CustomPointAnnotation else {
                return nil
            }

            let identifier = "CustomBuoyAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: mkAnnotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true

                // Customize marker appearance
                if let markerAnnotationView = annotationView as? MKMarkerAnnotationView {
                    markerAnnotationView.markerTintColor = UIColor.red
                    markerAnnotationView.glyphText = "B"  // Represents a buoy
                    markerAnnotationView.titleVisibility = .visible
                    markerAnnotationView.subtitleVisibility = .visible
                }

                // Add a detail disclosure button to the callout
                let detailButton = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = detailButton
            } else {
                annotationView!.annotation = mkAnnotation
            }

            return annotationView
        }

        // Handle tap on callout accessory (detail button)
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let mkAnnotation = view.annotation as? CustomPointAnnotation else { return }

            guard let matchingInstrument = mkAnnotation.instrument else {
                print("Could not find the matching instrument")
                return
            }

            guard let latestData = matchingInstrument.floatData.last else {
                // Show alert if no data is available
                let alert = UIAlertController(title: "Data Unavailable", message: "No float data available for this instrument.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                DispatchQueue.main.async {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        window.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
                return
            }

            // Prepare buoy data message
            let message = """
            UTC: \(DateFormatter.localizedString(from: mkAnnotation.dateTime ?? Date(), dateStyle: .medium, timeStyle: .short))
            GPS Lat/Lon: \(mkAnnotation.coordinate.latitude), \(mkAnnotation.coordinate.longitude)
            Battery: \(latestData.batteryLevel) mV
            Internal Pressure: \(latestData.internalPressure) Pa
            External Pressure: \(latestData.externalPressure) mbar
            Distance Travelled: \(latestData.distanceTravelled) km
            Average Speed: \(latestData.averageSpeed) km/h
            Net Displacement: \(latestData.netDisplacement) km
            GPS Accuracy: HDOP \(latestData.gpsAccuracyHdop) m, VDOP \(latestData.gpsAccuracyVdop) m
            """

            // Show alert with buoy data
            let alert = UIAlertController(title: "Buoy Data", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))

            DispatchQueue.main.async {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first {
                    window.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    // Create Coordinator instance
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // Create and configure MKMapView
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.region = region
        return mapView
    }

    // Update MKMapView with new data
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update map region if it has changed
        if mapView.region.center.latitude != region.center.latitude ||
           mapView.region.center.longitude != region.center.longitude ||
           mapView.region.span.latitudeDelta != region.span.latitudeDelta ||
           mapView.region.span.longitudeDelta != region.span.longitudeDelta {
            mapView.setRegion(region, animated: true)
        }

        // Update map type based on is3D toggle
        mapView.mapType = is3D ? .hybridFlyover : .standard

        // Update annotations
        mapView.removeAnnotations(mapView.annotations)
        let mkAnnotations = annotations.map { annotation -> CustomPointAnnotation in
            let mkAnnotation = CustomPointAnnotation()
            mkAnnotation.coordinate = annotation.coordinate
            mkAnnotation.title = annotation.title
            mkAnnotation.subtitle = annotation.subtitle
            mkAnnotation.instrument = annotation.instrument
            mkAnnotation.dateTime = annotation.dateTime
            return mkAnnotation
        }
        mapView.addAnnotations(mkAnnotations)

        // Update polylines
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlays(polylines)
    }
}

// MARK: - CustomPointAnnotation
/// Extends MKPointAnnotation to include additional buoy-related data.
class CustomPointAnnotation: MKPointAnnotation {
    var instrument: Instrument? // Associated instrument
    var dateTime: Date?        // Timestamp of the data
}
