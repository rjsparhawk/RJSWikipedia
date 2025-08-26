//
//  RootView.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/25/25.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            TextSearchView()
                .tabItem {
                    Label("Text", systemImage: "pencil.line")
                }
            MapSearchView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
        }
    }
}

#Preview {
    RootView()
}
