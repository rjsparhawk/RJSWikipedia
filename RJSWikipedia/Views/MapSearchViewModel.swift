//
//  MapSearchViewModel.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/26/25.
//

import Combine
import Foundation
import MapKit
import Observation
import SwiftUI

final class MapSearchViewModel: NSObject, ObservableObject {
    private let locationManager: CLLocationManager
    private let networkManager = NetworkManager()
    private var expectingLocation: Bool = false
    @Published var articles: [GeoSearchArticleData]?
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
    }
    
    func requestLocation() {
        expectingLocation = true
        locationManager.requestWhenInUseAuthorization()
    }
}

extension MapSearchViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            
            if expectingLocation == true {
                expectingLocation = false
                Task {
                    try await NetworkManager().searchByLocation(coordinates: "\(lat)|\(long)") { [weak self] result in
                        self?.articles = try? result.get().geoSearchResponseQuery?.articles ?? []
                    }
                }
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to get location: \(error)")
    }
}
