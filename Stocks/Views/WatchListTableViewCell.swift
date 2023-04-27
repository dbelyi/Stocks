//
//  WatchListTableViewCell.swift
//  Stocks
//
//  Created by Danila Belyi on 27.04.2023.
//

import UIKit

// MARK: - WatchListTableViewCellDelegate

protocol WatchListTableViewCellDelegate: AnyObject {
  func didUpdateMaxWidth()
}

// MARK: - WatchListTableViewCell

class WatchListTableViewCell: UITableViewCell {
  // MARK: Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.clipsToBounds = true
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
    let chartViewModel: StockChartView.ViewModel
  }

  static let identifier = "WatchListTableViewCell"

  static let prefferedHeight: CGFloat = 60

  weak var delegate: WatchListTableViewCellDelegate?

  override func layoutSubviews() {
    super.layoutSubviews()
    symbolLabel.sizeToFit()
    nameLabel.sizeToFit()
    priceLabel.sizeToFit()
    changeLabel.sizeToFit()

    symbolLabel.frame = CGRect(
      x: separatorInset.left,
      y: (contentView.height - symbolLabel.height - nameLabel.height) / 2,
      width: symbolLabel.width,
      height: symbolLabel.height
    )

    nameLabel.frame = CGRect(
      x: separatorInset.left,
      y: symbolLabel.bottom,
      width: nameLabel.width,
      height: nameLabel.height
    )

    let currentWidth = max(
      max(priceLabel.width, changeLabel.width),
      WatchListViewController.maxChangeWidth
    )

    if currentWidth > WatchListViewController.maxChangeWidth {
      WatchListViewController.maxChangeWidth = currentWidth
      delegate?.didUpdateMaxWidth()
    }

    priceLabel.frame = CGRect(
      x: contentView.width - 10 - currentWidth,
      y: (contentView.height - priceLabel.height - changeLabel.height) / 2,
      width: currentWidth,
      height: priceLabel.height
    )

    changeLabel.frame = CGRect(
      x: contentView.width - 10 - currentWidth,
      y: priceLabel.bottom,
      width: currentWidth,
      height: changeLabel.height
    )

    miniChartView.frame = CGRect(
      x: priceLabel.left - (contentView.width / 3) - 5,
      y: 6,
      width: contentView.width / 3,
      height: contentView.height - 12
    )
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

  private let miniChartView: StockChartView = {
    let chart = StockChartView()
    chart.clipsToBounds = true
    return chart
  }()

  private let symbolLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 15, weight: .regular)
    return label
  }()

  private let priceLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .right
    label.font = .systemFont(ofSize: 15, weight: .regular)
    return label
  }()

  private let changeLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .right
    label.textColor = .white
    label.font = .systemFont(ofSize: 15, weight: .regular)
    label.layer.masksToBounds = true
    label.layer.cornerRadius = 6
    return label
  }()
}
