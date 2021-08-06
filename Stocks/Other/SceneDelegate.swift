//
//  SceneDelegate.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/3/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
   
   /// Our mian app window
   var window: UIWindow?
   
   func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      guard let windowScene = (scene as? UIWindowScene) else { return }
      let window = UIWindow(windowScene: windowScene)
      let vc = WatchListVC()
      let navVC = UINavigationController(rootViewController: vc)
      window.rootViewController = navVC
      window.makeKeyAndVisible()
      self.window = window
   }

   func sceneDidDisconnect(_ scene: UIScene) {}

   func sceneDidBecomeActive(_ scene: UIScene) {}

   func sceneWillResignActive(_ scene: UIScene) {}

   func sceneWillEnterForeground(_ scene: UIScene) {}

   func sceneDidEnterBackground(_ scene: UIScene) {}

}

