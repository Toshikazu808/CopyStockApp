//
//  Constants.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/6/21.
//

import Foundation

final class Constants {
   
   enum NewsType {
      case topStories
      case company(symbol: String)
      var title: String {
         switch self {
         case .topStories:
            return "Top Stories"
         case .company(let symbol):
            return symbol.uppercased()
         }
      }
   }
}
