//
//  TopStoriesNewsViewController.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import SafariServices
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
    table.register(
      NewsStoryTableViewCell.self,
      forCellReuseIdentifier: NewsStoryTableViewCell.identifier
    )
    table.register(
      NewsHeaderView.self,
      forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier
    )
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

  private var stories = [NewsStory]()

  private func setUpTable() {
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }

  private func fetchNews() {
    APICaller.shared().news(for: type) { [weak self] result in
      switch result {
      case let .success(stories):
        DispatchQueue.main.async {
          self?.stories = stories
          self?.tableView.reloadData()
        }
      case let .failure(error):
        print(error)
      }
    }
  }

  private func open(url: URL) {
    let safariVC = SFSafariViewController(url: url)
    present(safariVC, animated: true)
  }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return stories.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: NewsStoryTableViewCell.identifier,
      for: indexPath
    ) as? NewsStoryTableViewCell else { fatalError() }
    cell.configure(with: .init(model: stories[indexPath.row]))
    return cell
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let header = tableView
      .dequeueReusableHeaderFooterView(
        withIdentifier: NewsHeaderView
          .identifier
      ) as? NewsHeaderView else { return nil }
    header.configure(with: .init(title: type.title, shouldShowAddButton: false))
    return header
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return NewsStoryTableViewCell.preferredHeight
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return NewsHeaderView.prefferedHeight
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let story = stories[indexPath.row]
    guard let url = URL(string: story.url) else {
      presentFailedToOpenAlert()
      return
    }
    open(url: url)
  }

  private func presentFailedToOpenAlert() {
    let alert = UIAlertController(
      title: "Unable to Open",
      message: "We were unable to open the article.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "Dissmis", style: .cancel))
    present(alert, animated: true)
  }
}
