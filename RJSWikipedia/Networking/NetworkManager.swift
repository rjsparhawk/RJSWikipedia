//
//  NetworkManager.swift
//  RJSWikipedia
//
//  Created by Robert Sparhawk on 8/24/25.
//

import Foundation

enum Host: String {
    case wikipedia = "https://api.wikimedia.org/"
}

enum Endpoint: String {
    case articleOfTheDay = "feed/v1/wikipedia/en/featured/"
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
        let request = try request(host: .wikipedia, endpoint: .articleOfTheDay)
        
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
    
    // MARK: - Common
    private func request(host: Host, endpoint: Endpoint) throws -> URLRequest {
        let urlString = host.rawValue + endpoint.rawValue + dateFormatter.string(from: Date())
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        print("Created request for \(urlString)")
        
        return URLRequest(url: url)
    }
    
}

enum NetworkError: Error {
    case invalidURL
    case invalidJson
}

extension Data {
    var prettyString: NSString {
        return NSString(data: self, encoding: String.Encoding.utf8.rawValue) ?? "Bad JSON"
    }
}
