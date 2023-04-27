//
//  MarketDataResponse.swift
//  Stocks
//
//  Created by Danila Belyi on 27.04.2023.
//

import Foundation

// MARK: - MarketDataResponse

struct MarketDataResponse: Codable {
  enum CodingKeys: String, CodingKey {
    case close = "c"
    case high = "h"
    case low = "l"
    case open = "o"
    case status = "s"
    case timestamps = "t"
  }

  let close: [Double]
  let high: [Double]
  let low: [Double]
  let open: [Double]
  let status: String
  let timestamps: [TimeInterval]

  var candleSticks: [CandleStick] {
    var result = [CandleStick]()

    for index in 0 ..< open.count {
      result.append(.init(
        date: Date(timeIntervalSince1970: timestamps[index]),
        high: high[index],
        low: low[index],
        open: open[index],
        close: close[index]
      ))
    }

    let sortedData = result.sorted { $0.date > $1.date }

    print(sortedData[0])

    return result
  }
}

// MARK: - CandleStick

struct CandleStick {
  let date: Date
  let high: Double
  let low: Double
  let open: Double
  let close: Double
}
