//
//  AppDelegate.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  /// This method is called by the system when the app finishes launching. It provides an opportunity to perform additional setup or configuration before the app becomes visible to the user.
  ///
  /// - Parameters:
  ///   - application: An instance of ﻿`UIApplication` representing the app itself.
  ///   - launchOptions: A dictionary containing any launch options passed to the app at startup.
  /// - Returns: A Boolean value `true` if the app launch was successful and the app can continue to run or ﻿`false` if the app launch was unsuccessful and the app should immediately terminate.
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  )
    -> Bool {
    return true
  }

  // MARK: UISceneSession Lifecycle

  /// This method is called when the app establishes a connection to a new scene session. It is responsible for providing a ﻿`UISceneConfiguration` object that represents the initial state of the scene.
  ///
  /// - Parameters:
  ///   - application: The instance of the ﻿`UIApplication` class that is responsible for managing the app’s life cycle.
  ///   - connectingSceneSession: The instance of the ﻿`UISceneSession` class that represents the new connecting scene session.
  ///   - options: An instance of ﻿`UIScene.ConnectionOptions` that provides additional information about the new scene session.
  /// - Returns: An instance of the ﻿`UISceneConfiguration` class that represents the initial state of the scene.
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  )
    -> UISceneConfiguration {
    return UISceneConfiguration(
      name: "Default Configuration",
      sessionRole: connectingSceneSession.role
    )
  }

  /// This method is a built-in function in the `UIApplication` class that gets called when the system discards a scene session.
  ///
  /// - Parameters:
  ///   - application: A `UIApplication` object representing the app requesting to discard the scene sessions.
  ///   - sceneSessions: A set of `UISceneSession` objects that represent the scene sessions being discarded.
  func application(
    _ application: UIApplication,
    didDiscardSceneSessions sceneSessions: Set<UISceneSession>
  ) {}
}
