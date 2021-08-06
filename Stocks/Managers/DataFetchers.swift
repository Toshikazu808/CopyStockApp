//
//  DataFetchers.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/6/21.
//

import Foundation

protocol DataFetchersDelegateWatchList {
   func updateWatchlist(from candleSticks: [CandleStick], and symbol: String)
   func updateUI()
}

protocol DataFetchersDelegateNews {
   func updateUI(from stories: [NewsStory])
}

struct DataFetchers {
   var delegateWatchList: DataFetchersDelegateWatchList?
   var delegateNews: DataFetchersDelegateNews?
   
   // References:
   // WatchListVC
   func fetchWatchlistData(using watchlistMap: [String: [CandleStick]]) {
      print(#function)
      let symbols = PersistenceManager.shared.watchList
      let group = DispatchGroup()
      for symbol in symbols where watchlistMap[symbol] == nil {
         group.enter()
         APICaller.shared.marketData(for: symbol) { result in
            defer {
               group.leave()
            }
            switch result {
            case .success(let data):
               let candleSticks = data.candleSticks
               delegateWatchList?.updateWatchlist(from: candleSticks, and: symbol)
            case .failure(let error):
               print(error)
            }
         }
      }
      group.notify(queue: .main) {
         delegateWatchList?.updateUI()
      }
   }
   
   // References:
   // NewsVC, StockDetailsVC
   func fetchNews(type: NewsVC.`Type`) {
      APICaller.shared.news(for: type) { result in
         switch result {
         case .success(let stories):
            DispatchQueue.main.async {
               delegateNews?.updateUI(from: stories)
            }
         case.failure(let error):
            print(error)
         }
      }
   }
   
}
