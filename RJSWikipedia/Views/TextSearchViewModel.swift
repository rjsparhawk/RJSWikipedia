//
//  TextSearchViewModel.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/26/25.
//

import Foundation
import SwiftUI

@MainActor
final class TextSearchViewModel: NSObject, ObservableObject {
    @Published var articles: [TextSearchArticleData]?
    @Published var showingError = false
    
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        super.init()
    }
    
    func search(with text: String) async {
        do {
            try await networkManager.searchByText(text) { result in
                DispatchQueue.main.async { [weak self] in
                    do {
                        self?.articles = try result.get().textSearchResponseQuery?.articles ?? []
                    } catch {
                        self?.showingError = true
                    }
                }
            }
        } catch {
            showingError = true
        }
    }
}
