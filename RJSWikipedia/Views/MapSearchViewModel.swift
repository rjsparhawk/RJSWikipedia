//
//  MapSearchViewModel.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/26/25.
//

import MapKit
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
    
    func searchAtCoordinates(lat: Double, lon: Double) {
        Task {
            do {
                try await NetworkManager().searchByLocation(coordinates: "\(lat)|\(lon)") { [weak self] result in
                    self?.articles = try? result.get().geoSearchResponseQuery?.articles ?? []
                }
            } catch {
                print("Failed to fetch data: \(error)")
            }
        }
    }
}

extension MapSearchViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            if expectingLocation == true {
                expectingLocation = false
                searchAtCoordinates(lat: lat, lon: lon)
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
