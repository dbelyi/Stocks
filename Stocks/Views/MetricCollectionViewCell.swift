//
//  MetricCollectionViewCell.swift
//  Stocks
//
//  Created by Danila Belyi on 09.05.2023.
//

import UIKit

class MetricCollectionViewCell: UICollectionViewCell {
  // MARK: - Lifecycle

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.clipsToBounds = true
    contentView.addSubviews(nameLabel, valueLabel)
  }

  // MARK: - Internal

  struct ViewModel {
    let name: String
    let value: String
  }

  static let identifier = "MetricCollectionViewCell"

  override func layoutSubviews() {
    super.layoutSubviews()
    valueLabel.sizeToFit()
    nameLabel.sizeToFit()
    nameLabel.frame = CGRect(
      x: 3,
      y: 0,
      width: nameLabel.width,
      height: contentView.height
    )
    valueLabel.frame = CGRect(
      x: nameLabel.right + 3,
      y: 0,
      width: valueLabel.width,
      height: contentView.height
    )
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    valueLabel.text = nil
  }

  func configure(with viewModel: ViewModel) {
    nameLabel.text = viewModel.name + ":"
    valueLabel.text = viewModel.value
  }

  // MARK: - Private

  private let nameLabel: UILabel = {
    let label = UILabel()

    return label
  }()

  private let valueLabel: UILabel = {
    let label = UILabel()
    label.textColor = .secondaryLabel
    return label
  }()
}
