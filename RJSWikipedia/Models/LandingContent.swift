//
//  LandingContent.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/24/25.
//

public struct LandingContent: Codable {
    var tfa: TodayFeaturedArticle?
}

public struct TodayFeaturedArticle: Codable {
    enum CodingKeys: String, CodingKey {
        case displayTitle = "displaytitle"
    }
    
    var displayTitle: String?
}
