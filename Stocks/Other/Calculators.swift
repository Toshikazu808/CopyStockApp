//
//  Calculators.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/6/21.
//

import Foundation

final class Calculators {
   static let shared = Calculators()
   
   public func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
      let latestDate = data[0].date
      guard let latestClose = data.first?.close,
            let priorClose = data.first(where: {
               !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
            })?.close else {
         return 0
      }
      let difference = 1 - (priorClose / latestClose)
      return difference
   }
   
   public func getLatestClosingPrice(from data: [CandleStick]) -> String {
      guard let closingPrice = data.first?.close else { return "" }
      return String.formatted(number: closingPrice)
   }
}
