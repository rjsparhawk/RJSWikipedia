//
//  ArticleRowView.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/25/25.
//

import SwiftUI

struct ArticleRowView: View {
    @State var viewModel: ArticleRowViewModel
    
    init(viewModel: ArticleRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                if let title = viewModel.articleData.title {
                    Text(title)
                        .font(.title2)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                if let extract = viewModel.articleData.extract {
                    Text(extract)
                        .font(.caption)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding([.leading], 10)
            
            Spacer(minLength: 10)
            
            if let imageUrlString = viewModel.articleData.thumbnail?.url,
               let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { result in
                    result.image?
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 80, height: 80)
                .padding([.trailing, .top, .bottom], 10)
            } else {
                Image(.dockwa)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding([.trailing, .top, .bottom], 10)
            }
        }
        .onTapGesture {
            if let wikipediaUrl = viewModel.articleData.wikipediaURL {
                UIApplication.shared.open(wikipediaUrl)
            }
        }
        .background(Color.cell)
    }
}

#Preview {
    ArticleRowView(
        viewModel: ArticleRowViewModel(
            articleData: ArticleData(
                title: "Title",
                pageId: 1,
                extract: "Extract",
                thumbnail: nil
            )
        )
    )
}
