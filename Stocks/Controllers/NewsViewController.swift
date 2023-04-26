//
//  TopStoriesNewsViewController.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import UIKit

// MARK: - NewsViewController

class NewsViewController: UIViewController {
  // MARK: Lifecycle

  init(type: Type) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: Internal

  enum `Type` {
    case topStories
    case company(symbol: String)

    // MARK: Internal

    var title: String {
      switch self {
      case .topStories:
        return "Top Stories"
      case let .company(symbol):
        return symbol.uppercased()
      }
    }
  }

  let tableView: UITableView = {
    let table = UITableView()
    table.backgroundColor = .clear
    return table
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpTable()
    fetchNews()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }

  // MARK: Private

  private let type: Type

  private func setUpTable() {
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }

  private func fetchNews() {}

  private func open(url: URL) {}
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return nil
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 140
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 70
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
