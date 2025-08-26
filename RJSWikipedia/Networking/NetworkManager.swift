//
//  NetworkManager.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/24/25.
//

import Foundation

enum Host: String {
    case wikipedia = "https://en.wikipedia.org/"
    case wikimedia = "https://api.wikimedia.org/"
}

enum Endpoint {
    case articleOfTheDay
    case textSearch(searchText: String)
    
    var httpMethod: String {
        "GET"
    }
    
    var route: String {
        switch self {
        case .articleOfTheDay:
            return "feed/v1/wikipedia/en/featured/"
        case .textSearch(_):
            return "w/api.php"
        }
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .articleOfTheDay:
            return nil
        case .textSearch(let searchText):
            return [
                "action": "query",
                "format": "json",
                "generator": "search",
                "gsrsearch": searchText,
                "gsrlimit": "50",
                "prop": "extracts|pageimages",
                "exlimit": "max",
                "list": "search",
                "redirects": "1",
                "formatversion": "2",
                "piprop": "thumbnail",
                "pilimit": "max",
                "pithumbsize": "200",
                "srsearch": searchText,
                "exintro": "1",
                "explaintext": "1"
            ]
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidJson
}

final class NetworkManager {
    
    // MARK: - Properties
    private let session: URLSession = .shared
    private let currentHost = Host.wikipedia
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    // MARK: - Network calls
    func fetchLandingContent(completion: @escaping (Result<LandingContent, Error>) -> Void) async throws {
        let request = try request(host: .wikimedia, endpoint: .articleOfTheDay)
        
        let task = session.dataTask(with: request) { data, _, error in
            if let data,
               let landingContent = try? JSONDecoder().decode(LandingContent.self, from: data) {
                print("Today's featured article: \(String(describing: landingContent.tfa?.displayTitle))")
                completion(.success(landingContent))
            } else {
                completion(.failure(NetworkError.invalidJson))
            }
        }
        task.resume()
    }
    
    func searchByText(_ text: String, completion: @escaping (Result<TextSearchResults, Error>) -> Void) async throws {
        let request = try request(host: currentHost, endpoint: .textSearch(searchText: text))
        let task = session.dataTask(with: request) { data, _, error in
            if let data,
               let textSearchResults = try? JSONDecoder().decode(TextSearchResults.self, from: data) {
                print("Search results: \(textSearchResults)")
                completion(.success(textSearchResults))
            } else {
                completion(.failure(NetworkError.invalidJson))
            }
        }
        task.resume()
    }
    
    // MARK: - Common
    private func request(host: Host, endpoint: Endpoint) throws -> URLRequest {
        var urlString = host.rawValue + endpoint.route
        
        switch endpoint {
        case .articleOfTheDay:
            // AOTD date is baked into the route, not query params
            urlString.append(dateFormatter.string(from: Date()))
        default:
            break
        }
        
        var components = URLComponents(string: urlString)
        components?.queryItems = endpoint.queryParameters?.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        print("Creating request for \(String(describing: components?.url))")
        
        guard let components,
              let url = components.url else {
            throw NetworkError.invalidURL
        }
            
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod
        
        return request
    }
    
}

extension Data {
    var prettyString: NSString {
        return NSString(data: self, encoding: String.Encoding.utf8.rawValue) ?? "Bad JSON"
    }
}

struct TextSearchResults: Codable {
    var textSearchResponseQuery: TextSearchResponseQuery?
    
    enum CodingKeys: String, CodingKey {
        case textSearchResponseQuery = "query"
    }
}

struct TextSearchResponseQuery: Codable {
    var articles: [ArticleData]?
    
    enum CodingKeys: String, CodingKey {
        case articles = "pages"
    }
}

struct ArticleData: Codable, Identifiable {
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
