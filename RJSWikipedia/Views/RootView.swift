//
//  RootView.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/25/25.
//

import MapKit
import SwiftUI

struct RootView: View {
    let networkManager = NetworkManager()
    let locationManager = CLLocationManager()
    
    var body: some View {
        TabView {
            TextSearchView(
                viewModel: TextSearchViewModel(networkManager: networkManager)
            )
            .tabItem {
                Label("Text", systemImage: "pencil.line")
            }
            MapSearchView(
                viewModel: MapSearchViewModel(
                    locationManager: locationManager,
                    networkManager: networkManager
                )
            )
            .tabItem {
                Label("Map", systemImage: "map")
            }
        }
    }
}

#Preview {
    RootView()
}
