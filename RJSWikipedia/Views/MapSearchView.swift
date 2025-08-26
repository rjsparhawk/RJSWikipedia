//
//  MapSearchView.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/25/25.
//

import Combine
import MapKit
import SwiftUI

struct MapSearchView: View {
    @StateObject private var viewModel = MapSearchViewModel(locationManager: CLLocationManager())
    @State private var selectedItem: GeoSearchArticleData?
    var body: some View {
        Map {
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
        .task {
            // Fire request on first appear - to remove
            viewModel.requestLocation()
        }
    }
}

#Preview {
    MapSearchView()
}
