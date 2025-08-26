//
//  ContentView.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/24/25.
//

import SwiftUI

struct TextSearchView: View {
    @StateObject var viewModel: TextSearchViewModel
    @State private var queryText: String = ""
        
    init(viewModel: TextSearchViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Spacer()
                Text("⬆️ Search up here! ⬆️")
                Spacer()
            }
            
            VStack(spacing: 0) {
                TextField(
                    "",
                    text: $queryText,
                    prompt: Text("Search Wikipedia...")
                        .foregroundStyle(.gray)
                )
                .padding(.all, 10)
                .onSubmit {
                    Task {
                        await viewModel.search(with: queryText)
                    }
                }
                .background(Color.textfield)
                .foregroundStyle(.black)
                
                List(viewModel.articles ?? []) { article in
                    ArticleRowView(viewModel: ArticleRowViewModel(articleData: article))
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
            }
        }
        .background(Color.background)
        .alert("Error", isPresented: $viewModel.showingError, actions: {
            // Leave empty to use the default "OK" action.
        }, message: {
            Text("We are unable to search right now. Please try again later.")
        })
    }
    
    
}

#Preview {
    TextSearchView(viewModel: TextSearchViewModel(networkManager: NetworkManager()))
}
