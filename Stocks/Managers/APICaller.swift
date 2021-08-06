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
      static let apiKey = "c44oruaad3i82cb9t7b0"
      static let sandboxApiKey = "sandbox_c44oruaad3i82cb9t7bg"
      static let baseUrl = "https://finnhub.io/api/v1/"
      static let day: TimeInterval = 60 * 60 * 24 // seconds
   }
   
   // MARK: - Public
   public func search(query: String, completion: @escaping(Result<SearchResponse, Error>) -> Void) {
      guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
      let url = url(
         for: .search,
         queryParams: ["q": safeQuery])
      request(
         url: url,
         expecting: SearchResponse.self,
         completion: completion)
   }
   
   public func news(for newsType: NewsVC.`Type`, completion: @escaping (Result<[NewsStory], Error>) -> Void) {
      print("\n\(#function)")
      switch newsType {
      case .topStories:
         let url = url(
            for: .topStories,
            queryParams: ["categories": "general"])
         request(
            url: url,
            expecting: [NewsStory].self,
            completion: completion)
      case .company(let symbol):
         let today = Date()
         let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7)) // units are in seconds
         let url = url(
            for: .companyNews,
            queryParams: [
               "symbol": symbol,
               "from": DateFormatter.newsDateFormatter.string(from: oneMonthBack),
               "to": DateFormatter.newsDateFormatter.string(from: today)
            ])
         request(
            url: url,
            expecting: [NewsStory].self,
            completion: completion)
      }
   }
   
   public func marketData(for symbol: String, numberOfDays: TimeInterval = 7, completion: @escaping(Result<MarketDataResponse, Error>) -> Void) {
      print("\n\(#function)")
      let today = Date().addingTimeInterval(-(Constants.day))
      let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
      let url = url(
         for: .marketData,
         queryParams: [
            "symbol": symbol,
            "resolution": "1",
            "from": "\(Int(prior.timeIntervalSince1970))",
            "to": "\(Int(today.timeIntervalSince1970))"])
      request(
         url: url,
         expecting: MarketDataResponse.self,
         completion: completion)
   }
   
   public func financialMetrics(for symbol: String, completion: @escaping (Result<FinancialMetricsResponse, Error>) -> Void) {
      let url = url(
         for: .financials,
         queryParams: ["symbol": symbol, "metric": "all"])
      request(
         url: url,
         expecting: FinancialMetricsResponse.self,
         completion: completion)
   }
   // Search stocks
   
   
   // MARK: - Private
   
   private enum Endpoint: String {
      case search
      case topStories = "news"
      case companyNews = "company-news"
      case marketData = "stock/candle"
      case financials = "stock/metric"
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
      return URL(string: urlString)
   }
   
   private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
      guard let url = url else {
         completion(.failure(APIError.invalidUrl))
         return
      }
      print(url)
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
