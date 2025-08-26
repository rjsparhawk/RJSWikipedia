//
//  ContentView.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/24/25.
//

import SwiftUI

struct TextSearchView: View {
    @State var articles: [TextSearchArticleData]?
    @State private var queryText: String = ""
    @State private var showingError: Bool = false
    private var networkManager = NetworkManager()
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Spacer()
                Text("⬆️ Search up here! ⬆️")
                Spacer()
            }
            
            VStack(spacing: 0) {
                TextField(
                    "Search Wikipedia...",
                    text: $queryText
                )
                .padding(.all, 10)
                .onSubmit {
                    Task {
                        await search(with: queryText)
                    }
                }
                .background(Color.textfield)
                
                
                List(articles ?? []) { article in
                    ArticleRowView(viewModel: ArticleRowViewModel(articleData: article))
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .scrollContentBackground(.hidden)
                .alert("Error", isPresented: $showingError, actions: {
                    // Leave empty to use the default "OK" action.
                }, message: {
                    Text("We are unable to search right now. Please try again later.")
                })
                .listStyle(PlainListStyle())
            }
        }
        .background(Color.background)
    }
    
    private func search(with text: String) async {
        do {
            try await networkManager.searchByText(text) { result in
                articles = try! result.get().textSearchResponseQuery?.articles ?? []
            }
        } catch {
            showingError = true
        }
    }
}

#Preview {
    TextSearchView()
}
