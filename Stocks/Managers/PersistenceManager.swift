//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/3/21.
//

import Foundation
// ["AAPL", "MSFT", "SNAP"]
// [AAPL: Apple Inc.]


final class PersistenceManager {
   private init() {}
   static let shared = PersistenceManager()
   private let userDefaults: UserDefaults = .standard
   private struct Constants {
      static let onboardedKey = "hasOnboarded"
      static let watchlistKey = "watchlist"
   }
   
   // MARK: - Public
   public var watchList: [String] {
      if !hasOnboarded {
         userDefaults.setValue(true, forKey: Constants.onboardedKey)
         setUpDefaults()
      }
      return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
   }
   
   public func watchlistContains(symbol: String) -> Bool {
      return watchList.contains(symbol)
   }
   
   public func addToWatchList(symbol: String, companyName: String) {
      var current = watchList
      current.append(symbol.uppercased())
      userDefaults.set(current, forKey: Constants.watchlistKey)
      userDefaults.set(companyName, forKey: symbol)
      NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
   }
   
   public func removeFromWatchList(symbol: String) {
      var newList = [String]()
      // Important to remove data from saved memory
      userDefaults.set(nil, forKey: symbol)
      for item in watchList where item != symbol {
         newList.append(item)
      }
      userDefaults.set(newList, forKey: Constants.watchlistKey)
   }
   
   // MARK: - Private
   
   private var hasOnboarded: Bool {
      return userDefaults.bool(forKey: Constants.onboardedKey)
   }
   
   private func setUpDefaults() {
      let map: [String: String] = [
         "AAPL": "Apple Inc",
         "MSFT": "Microsoft Corporation",
         "GOOG": "Alphabet",
         "AMZN": "Amazon.com, Inc.",
         "WORK": "Slack Technologies",
         "FB": "Facebook Inc.",
         "NVDA": "Nvidia Inc.",
         "NKE": "Nike",
         "PINS": "Pinterest Inc.",
         "SNAP": "Snap Inc."
      ]
      let symbols = map.keys.map { $0 }
      userDefaults.set(symbols, forKey: Constants.watchlistKey)
      for (symbol, name) in map {
         userDefaults.set(name, forKey: symbol)
      }
   }
   
}
