//
//  APICaller.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/3/21.
//

import Foundation

final class APICaller {
   private init() {}
   static let shared = APICaller()
   private struct Constants {
      static let apiKey = ""
      static let sandboxApiKey = ""
      static let baseUrl = ""
   }
   
   // MARK: - Public
   public func search(query: String, completion: @escaping(Result<SearchResponse, Error>) -> Void) {
      guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
      request(url: url(for: .search, queryParams: ["q":safeQuery]), expecting: SearchResponse.self, completion: completion)
   }
   
   // Get stock info
   
   // Search stocks
   
   
   // MARK: - Private
   
   private enum Endpoint: String {
      case search
   }
   
   private enum APIError: Error {
      case invalidUrl
      case noDataReturned
   }
   
   private func url(for endpoint: Endpoint, queryParams: [String: String] = [:] ) -> URL? {
      var urlString = Constants.baseUrl + endpoint.rawValue
      var queryItems = [URLQueryItem]()
      for (key, value) in queryParams { // Add any parameters
         queryItems.append(.init(name: key, value: value))
      }
      // Add token
      queryItems.append(.init(name: "token", value: Constants.apiKey))
      
      // Convert query itmes to suffix string
      urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
      print("\n\(urlString)\n")
      
      return URL(string: urlString)
   }
   
   private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
      guard let url = url else {
         completion(.failure(APIError.invalidUrl))
         return
      }
      let task = URLSession.shared.dataTask(with: url) { data, response, error in
         guard let data = data, error == nil else {
            if let error = error {
               completion(.failure(error))
            } else {
               completion(.failure(APIError.noDataReturned))
            }
            return
         }
         do {
            let result = try JSONDecoder().decode(expecting, from: data)
            completion(.success(result))
         } catch {
            completion(.failure(error))
         }
      }
      task.resume()
   }
   
}