//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/3/21.
//

import Foundation

final class PersistenceManager {
   private init() {}
   static let shared = PersistenceManager()
   private let userDefaults: UserDefaults = .standard
   private struct Constants {
      
   }
   
   
   
   // MARK: - Public
   public var watchList: [String] {
      return []
   }
   
   public func addToWatchList() {
      
   }
   
   public func removeFromWatchList() {
      
   }
   
   // MARK: - Private
   
   private var hasOnboarded: Bool {
      return false
   }
   
   
}
