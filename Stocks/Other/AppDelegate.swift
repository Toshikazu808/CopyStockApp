//
//  AppDelegate.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/3/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      return true
   }

   // MARK: UISceneSession Lifecycle

   func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
      return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
   }

   func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
      
   }

   // MARK: - Testing API calls upon launch
   private func debug() {
//      APICaller.shared.news(for: .company(symbol: "AAPL")) { result in
//         print(result)
//         switch result {
//         case .success(let news):
//            print(news.count)
//         case .failure(let error):
//            print(error)
//         }
//      }
      
//      APICaller.shared.marketData(for: "AAPL", numberOfDays: 1) { result in
//         print(result)
//         switch result {
//         case .success(let data):
//            let candleSticks = data.candleSticks
//         case .failure(let error):
//            print(error)
//         }
//      }
   }
}

