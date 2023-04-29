//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import UIKit

class StockDetailsViewController: UIViewController {
  // MARK: Lifecycle

  init(symbol: String, companyName: String, candleStickData: [CandleStick] = []) {
    self.symbol = symbol
    self.companyName = companyName
    self.candleStickData = candleStickData
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
  }

  // MARK: Private

  private let symbol: String

  private let companyName: String

  private var candleStickData: [CandleStick]
}
