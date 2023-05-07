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

  public func addToWatchlist(symbol: String, companyName: String) {
    var current = watchlist
    current.append(symbol)
    userDefaults.set(current, forKey: Constants.watchlistKey)
    userDefaults.set(companyName, forKey: symbol)
    NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
  }

  public func removeFromWatchlist(symbol: String) {
    var newList = [String]()

    userDefaults.set(nil, forKey: symbol)

    for item in watchlist where item != symbol {
      newList.append(item)
    }

    userDefaults.set(newList, forKey: Constants.watchlistKey)
  }

  // MARK: Internal

  static let shared = PersistenceManager()

  public var watchlist: [String] {
    if !hasOnboarded {
      userDefaults.set(true, forKey: Constants.onboardedKey)
      setUpDefaults()
    }
    return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
  }
  
  public func watchlistContains(symbol: String) -> Bool {
    return watchlist.contains(symbol)
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
