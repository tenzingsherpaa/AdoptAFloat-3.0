//
//  MapView.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 8/30/24.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var is3D: Bool
    var annotations: [IdentifiablePointAnnotation]
    var polylines: [CustomPolyline]
    var selectedDate: Date
    var instrument: Instrument?

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(parent: MapView) {
            self.parent = parent
            super.init()
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? CustomPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)

                // Calculate the time difference between the polyline's date and the selected date
                if let polylineDate = polyline.dateTime, let instrument = parent.instrument {
                    let timeDifference = parent.selectedDate.timeIntervalSince(polylineDate)
                    let totalTimeDifference = instrument.floatData.last?.dateTime.timeIntervalSince(instrument.floatData.first?.dateTime ?? Date()) ?? 1

                    // Normalize the time difference to get an alpha value between 0.1 and 1.0
                    let alpha = CGFloat(1.0 - (timeDifference / totalTimeDifference))
                    renderer.strokeColor = UIColor.blue.withAlphaComponent(alpha)
                } else {
                    renderer.strokeColor = UIColor.blue
                }

                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }

        // Remove any `updatePolylines` function from here
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.region = region
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if mapView.region.center.latitude != region.center.latitude ||
           mapView.region.center.longitude != region.center.longitude ||
           mapView.region.span.latitudeDelta != region.span.latitudeDelta ||
           mapView.region.span.longitudeDelta != region.span.longitudeDelta {
            mapView.setRegion(region, animated: true)
        }

        mapView.mapType = is3D ? .hybridFlyover : .standard

        // Remove existing annotations
        mapView.removeAnnotations(mapView.annotations)
        let mkAnnotations = annotations.map { annotation -> MKPointAnnotation in
            let mkAnnotation = MKPointAnnotation()
            mkAnnotation.coordinate = annotation.coordinate
            mkAnnotation.title = annotation.title
            mkAnnotation.subtitle = annotation.subtitle
            return mkAnnotation
        }
        mapView.addAnnotations(mkAnnotations)

        // Remove existing overlays
        mapView.removeOverlays(mapView.overlays)

        // Add new polylines
        mapView.addOverlays(polylines)
    }
}
