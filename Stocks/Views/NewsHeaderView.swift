//
//  NewsHeaderView.swift
//  Stocks
//
//  Created by Danila Belyi on 26.04.2023.
//

import UIKit

// MARK: - NewsHeaderViewDelegate

protocol NewsHeaderViewDelegate: AnyObject {
  func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView)
}

// MARK: - NewsHeaderView

class NewsHeaderView: UITableViewHeaderFooterView {
  // MARK: - Lifecycle

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    contentView.addSubviews(label, button)
    button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: - Public

  public func configure(with viewModel: ViewModel) {
    label.text = viewModel.title
    button.isHidden = !viewModel.shouldShowAddButton
  }

  // MARK: - Internal

  struct ViewModel {
    let title: String
    let shouldShowAddButton: Bool
  }

  static let identifier = "NewsHeaderView"
  static let prefferedHeight: CGFloat = 40

  weak var delegate: NewsHeaderViewDelegate?

  let button: UIButton = {
    let button = UIButton()
    button.setTitle("+ WatchList", for: .normal)
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 8
    button.layer.masksToBounds = true
    return button
  }()

  override func layoutSubviews() {
    super.layoutSubviews()
    label.frame = CGRect(x: 14, y: 0, width: contentView.width - 28, height: contentView.height)

    button.sizeToFit()
    button.frame = CGRect(
      x: contentView.width - button.width - 16,
      y: (contentView.height - button.height) / 2,
      width: button.width + 8,
      height: button.height
    )
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    label.text = nil
  }

  // MARK: - Private

  private let label: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 32)
    return label
  }()

  @objc
  private func didTapButton() {
    delegate?.newsHeaderViewDidTapAddButton(self)
  }
}
