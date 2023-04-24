//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import Foundation

final class PersistenceManager {
  // MARK: Lifecycle

  private init() {}

  // MARK: Public

  public func addToWatchlist() {}

  public func removeFromWatchlist() {}

  // MARK: Internal

  static let shared = PersistenceManager()

  var watchlist: [String] {
    return []
  }

  // MARK: Private

  private struct Constants {}

  private let userDefaults: UserDefaults = .standard

  private var hasOnboarded: Bool {
    return false
  }
}
