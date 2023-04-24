//
//  SearchResultsViewController.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import UIKit

// MARK: - SearchResultsViewControllerDelegate

protocol SearchResultsViewControllerDelegate: AnyObject {
  func searchResultsViewControllerDidSelect(searchResult: String)
}

// MARK: - SearchResultsViewController

class SearchResultsViewController: UIViewController {
  // MARK: Public

  public func update(with results: [String]) {
    self.results = results
    tableView.reloadData()
  }

  // MARK: Internal

  weak var delegate: SearchResultsViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setUpTable()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }

  // MARK: Private

  private var results: [String] = []

  private let tableView: UITableView = {
    let table = UITableView()
    table.register(
      SearchResultTableViewCell.self,
      forCellReuseIdentifier: SearchResultTableViewCell.identifier
    )
    return table
  }()

  private func setUpTable() {
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: SearchResultTableViewCell.identifier,
      for: indexPath
    )

    cell.textLabel?.text = "AAPL"
    cell.detailTextLabel?.text = "Apple Inc."

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    delegate?.searchResultsViewControllerDidSelect(searchResult: "AAPL")
  }
}
