//
//  Models.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/24/25.
//

import Foundation

public struct LandingContent: Codable {
    var tfa: TodayFeaturedArticle?
}

public struct TodayFeaturedArticle: Codable {
    enum CodingKeys: String, CodingKey {
        case displayTitle = "displaytitle"
    }
    
    var displayTitle: String?
}

struct TextSearchResults: Codable {
    var textSearchResponseQuery: TextSearchResponseQuery?
    
    enum CodingKeys: String, CodingKey {
        case textSearchResponseQuery = "query"
    }
}

struct GeoSearchResults: Codable {
    var geoSearchResponseQuery: GeoSearchResponseQuery?
    
    enum CodingKeys: String, CodingKey {
        case geoSearchResponseQuery = "query"
    }
}

struct GeoSearchResponseQuery: Codable {
    var articles: [GeoSearchArticleData]?
    
    enum CodingKeys: String, CodingKey {
        case articles = "geosearch"
    }
}

struct GeoSearchArticleData: Codable, Identifiable, Hashable {
    let id = UUID()
    
    var title: String?
    var pageId: Int?
    var lat: Double?
    var lon: Double?
    
    enum CodingKeys: String, CodingKey {
        case title
        case pageId = "pageid"
        case lat
        case lon
    }
}

struct TextSearchResponseQuery: Codable {
    var articles: [TextSearchArticleData]?
    
    enum CodingKeys: String, CodingKey {
        case articles = "pages"
    }
}

struct TextSearchArticleData: Codable, Identifiable {
    let id: String = UUID().uuidString
    
    var title: String?
    var pageId: Int?
    var extract: String?
    var thumbnail: Thumbnail?
    
    var wikipediaURL: URL? {
        guard let pageId = pageId else { return nil }
        return URL(string: "https://en.wikipedia.org/?curid=\(pageId)")
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case pageId = "pageid"
        case extract
        case thumbnail
    }
}

struct Thumbnail: Codable {
    var url: String?
    
    enum CodingKeys: String, CodingKey {
        case url = "source"
    }
}

