//
//  WatchListTableViewCell.swift
//  Stocks
//
//  Created by Danila Belyi on 27.04.2023.
//

import UIKit

class WatchListTableViewCell: UITableViewCell {
  // MARK: Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addSubviews(symbolLabel, nameLabel, miniChartView, priceLabel, changeLabel)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: Public

  public func configure(with viewModel: ViewModel) {
    symbolLabel.text = viewModel.symbol
    nameLabel.text = viewModel.companyName
    priceLabel.text = viewModel.price
    changeLabel.text = viewModel.changePercentage
    changeLabel.backgroundColor = viewModel.changeColor
  }

  // MARK: Internal

  struct ViewModel {
    let symbol: String
    let companyName: String
    let price: String
    let changeColor: UIColor
    let changePercentage: String
//    let chartViewModel: StockChartView.ViewModel
  }

  static let identifier = "WatchListTableViewCell"

  static let prefferedHeight: CGFloat = 60

  override func layoutSubviews() {
    super.layoutSubviews()
    
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    symbolLabel.text = nil
    nameLabel.text = nil
    priceLabel.text = nil
    changeLabel.text = nil
    miniChartView.reset()
  }

  // MARK: Private

  private let miniChartView = StockChartView()

  private let symbolLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 15, weight: .medium)
    return label
  }()

  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 15, weight: .regular)
    return label
  }()

  private let priceLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 15, weight: .regular)
    return label
  }()

  private let changeLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.font = .systemFont(ofSize: 15, weight: .regular)
    return label
  }()
}
