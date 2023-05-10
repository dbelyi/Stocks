//
//  SceneDelegate.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  /// Our main app window
  var window: UIWindow?

  /// This method is part of the `UISceneDelegate` protocol in the iOS UIKit framework. It is called when the system connects your app to a scene instance. You can use this method to do any additional setup in your app before the scene is displayed.
  ///
  /// - Parameters:
  ///   - scene: The scene object that this method deals with. You should check if the scene is of type ﻿`UIWindowScene`. Otherwise, the method will simply return without doing anything.
  ///   - session: The ﻿`UIWindowSceneSession` instance being used by the scene. You can use this to access any data associated with the session if needed.
  ///   - connectionOptions: The set of options used to create the connection with the scene.
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: windowScene)
    let vc = WatchListViewController()
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
