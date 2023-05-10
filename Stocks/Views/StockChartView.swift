//
//  StockChartView.swift
//  Stocks
//
//  Created by Danila Belyi on 27.04.2023.
//

import Charts
import UIKit

class StockChartView: UIView {
  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(chartView)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: - Internal

  struct ViewModel {
    let data: [Double]
    let showLegend: Bool
    let showAxis: Bool
    let fillColor: UIColor
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    chartView.frame = bounds
  }

  func reset() {
    chartView.data = nil
  }

  func configure(with viewModel: ViewModel) {
    var entries = [ChartDataEntry]()

    for (index, value) in viewModel.data.enumerated() {
      entries.append(.init(x: Double(index), y: value))
    }

    chartView.rightAxis.enabled = viewModel.showAxis
    chartView.legend.enabled = viewModel.showLegend

    let dataSet = LineChartDataSet(entries: entries, label: "7 Days")
    dataSet.fillColor = viewModel.fillColor
    dataSet.setColor(viewModel.fillColor)
    dataSet.lineWidth = 0.45
    dataSet.drawFilledEnabled = true
    dataSet.drawIconsEnabled = false
    dataSet.drawValuesEnabled = false
    dataSet.drawCirclesEnabled = false
    let data = LineChartData(dataSet: dataSet)
    chartView.data = data
  }

  // MARK: - Private

  private let chartView: LineChartView = {
    let chartView = LineChartView()
    chartView.pinchZoomEnabled = false
    chartView.setScaleEnabled(true)
    chartView.xAxis.enabled = false
    chartView.drawGridBackgroundEnabled = false
    chartView.legend.enabled = false
    chartView.leftAxis.enabled = false
    chartView.rightAxis.enabled = false
    return chartView
  }()
}
