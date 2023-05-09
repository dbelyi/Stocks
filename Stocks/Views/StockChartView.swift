//
//  StockChartView.swift
//  Stocks
//
//  Created by Danila Belyi on 27.04.2023.
//

import UIKit

class StockChartView: UIView {
  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: - Internal

  struct ViewModel {
    let data: [Double]
    let showLegend: Bool
    let showAxis: Bool
  }

  override func layoutSubviews() {
    super.layoutSubviews()
  }

  func reset() {
    // MARK: - TODO: Reset the chart view
  }

  func configure(with viewModel: ViewModel) {}
}
