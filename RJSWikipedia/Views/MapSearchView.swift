//
//  MapSearchView.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/25/25.
//

import MapKit
import SwiftUI

struct MapSearchView: View {
    @StateObject var viewModel: MapSearchViewModel
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var centerCoordinate: CLLocationCoordinate2D?
    
    init(viewModel: MapSearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Map(position: $mapPosition) {
                // If we have articles in memory
                if let articles = viewModel.articles {
                    // Filter out any with incomplete coordinate data
                    let filteredArticles = articles.filter {
                        $0.lat != nil && $0.lon != nil
                    }
                    // For each, generate a simple map marker
                    ForEach(filteredArticles) { article in
                        Marker(article.title ?? "", coordinate: CLLocationCoordinate2D(latitude: article.lat ?? 0, longitude: article.lon ?? 0))
                    }
                }
            }
            .onMapCameraChange { mapCameraUpdate in
                centerCoordinate = mapCameraUpdate.camera.centerCoordinate
            }
            .task {
                // Fire request on first appear - to remove
                viewModel.requestLocation()
            }
            HStack {
                Spacer()
                VStack {
                    Button {
                        if let lat = centerCoordinate?.latitude,
                           let lon = centerCoordinate?.longitude {
                            viewModel.searchAtCoordinates(lat: lat, lon: lon)
                        }
                    } label: {
                        Text("Search Here")
                    }
                    .buttonStyle(.borderedProminent)
                    .background(.button)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .padding(.trailing, 20)
                    Spacer()
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showingError, actions: {
            // Leave empty to use the default "OK" action.
        }, message: {
            Text("We are unable to search right now. Please try again later.")
        })
    }
}

#Preview {
    MapSearchView(viewModel: MapSearchViewModel(locationManager: CLLocationManager(), networkManager: NetworkManager()))
}
