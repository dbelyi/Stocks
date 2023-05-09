//
//  SearchResultTableViewCell.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: - Internal

  static let identifier = "SearchResultTableViewCell"
}
