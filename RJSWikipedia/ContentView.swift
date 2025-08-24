//
//  ContentView.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/24/25.
//

import SwiftUI

struct ContentView: View {
    @State var text: String = "Hello, World!"
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(text)
        }
        .padding()
        .task {
            let networkManager = NetworkManager()
            try! await networkManager.fetchLandingContent(completion: { result in
                guard let title = try? result.get().tfa?.displayTitle else { return }
                text = title
            })
        }
    }
}

#Preview {
    ContentView()
}
