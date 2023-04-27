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
    if !hasOnboarded {
      userDefaults.set(true, forKey: Constants.onboardedKey)
      setUpDefaults()
    }
    return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
  }

  // MARK: Private

  private enum Constants {
    static let onboardedKey = "hasOnboarded"
    static let watchlistKey = "watchlist"
  }

  private let userDefaults: UserDefaults = .standard

  private var hasOnboarded: Bool {
    return userDefaults.bool(forKey: Constants.onboardedKey)
  }

  private func setUpDefaults() {
    let map: [String: String] = [
      //      "APPL": "Apple Inc.",
      "MSFT": "Microsoft Corporation",
      "SNAP": "Snap Inc.",
      "GOOG": "Alphabet",
      "AMZN": "Amazon.com Inc.",
//      "WORK": "Slack Technologies",
//      "FB": "Facebook Inc.",
      "NVDA": "NVidia Inc.",
      "NKE": "Nike",
      "PINS": "Pinterest Inc.",
    ]

    let symbols = map.keys.map { $0 }
    userDefaults.set(symbols, forKey: Constants.watchlistKey)

    for (symbol, name) in map {
      userDefaults.set(name, forKey: symbol)
    }
  }
}
