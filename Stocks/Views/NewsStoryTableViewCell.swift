//
//  NewsStoryTableViewCell.swift
//  Stocks
//
//  Created by Danila Belyi on 26.04.2023.
//

import SDWebImage
import UIKit

class NewsStoryTableViewCell: UITableViewCell {
  // MARK: Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.backgroundColor = .secondarySystemBackground
    backgroundColor = .secondarySystemBackground
    addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: Public

  public func configure(with viewModel: ViewModel) {
    headlineLabel.text = viewModel.headline
    sourceLabel.text = viewModel.source
    dateLabel.text = viewModel.dateString
    storyImageView.sd_setImage(with: viewModel.imageURL)

    // Manually set image
    // storyImageView.setImage(with: viewModel.imageURL)
  }

  // MARK: Internal

  struct ViewModel {
    // MARK: Lifecycle

    init(model: NewsStory) {
      self.source = model.source
      self.headline = model.headline
      self.dateString = String.string(from: model.datetime)
      self.imageURL = URL(string: model.image)
    }

    // MARK: Internal

    let source: String
    let headline: String
    let dateString: String
    let imageURL: URL?
  }

  static let identifier = "NewsStoryTableViewCell"

  static let preferredHeight: CGFloat = 140

  override func layoutSubviews() {
    super.layoutSubviews()

    let imageSize: CGFloat = contentView.height / 1.4
    storyImageView.frame = CGRect(
      x: contentView.width - imageSize - 10,
      y: (contentView.height - imageSize) / 2,
      width: imageSize,
      height: imageSize
    )

    let aviableWidth: CGFloat = contentView.width - separatorInset.left - imageSize - 15
    dateLabel.frame = CGRect(
      x: separatorInset.left,
      y: contentView.height - 40,
      width: aviableWidth,
      height: 40
    )

    sourceLabel.sizeToFit()
    sourceLabel.frame = CGRect(
      x: separatorInset.left,
      y: 4,
      width: aviableWidth,
      height: sourceLabel.height
    )

    headlineLabel.frame = CGRect(
      x: separatorInset.left,
      y: sourceLabel.bottom + 5,
      width: aviableWidth,
      height: contentView.height - sourceLabel.bottom - dateLabel.height - 10
    )
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    sourceLabel.text = nil
    headlineLabel.text = nil
    dateLabel.text = nil
    storyImageView.image = nil
  }

  // MARK: Private

  private let sourceLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14, weight: .medium)
    return label
  }()

  private let headlineLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 22, weight: .regular)
    label.numberOfLines = 0
    return label
  }()

  private let dateLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14, weight: .light)
    label.textColor = .secondaryLabel
    return label
  }()

  private let storyImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = .tertiarySystemBackground
    imageView.layer.cornerRadius = 6
    imageView.layer.masksToBounds = true
    return imageView
  }()
}
