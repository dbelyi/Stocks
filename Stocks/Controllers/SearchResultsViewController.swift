//
//  SearchResultsViewController.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import UIKit

// MARK: - SearchResultsViewControllerDelegate

protocol SearchResultsViewControllerDelegate: AnyObject {
  func searchResultsViewControllerDidSelect(searchResult: SearchResult)
}

// MARK: - SearchResultsViewController

class SearchResultsViewController: UIViewController {
  // MARK: - Public

  public func update(with results: [SearchResult]) {
    self.results = results
    updateTableView()
  }

  // MARK: - Internal

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

  // MARK: - Private

  private let tableView: UITableView = {
    let table = UITableView()
    table.register(
      SearchResultTableViewCell.self,
      forCellReuseIdentifier: SearchResultTableViewCell.identifier
    )
    table.isHidden = true
    return table
  }()

  private var results: [SearchResult] = [] {
    didSet {
      updateTableView()
    }
  }

  private func updateTableView() {
    tableView.reloadData()
    tableView.isHidden = results.isEmpty
  }

  private func setUpTable() {
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: SearchResultTableViewCell.identifier,
      for: indexPath
    ) as? SearchResultTableViewCell else {
      fatalError("Unable to dequeue SearchResultTableViewCell")
    }

    let model = results[indexPath.row]

    cell.textLabel?.text = model.displaySymbol
    cell.detailTextLabel?.text = model.description

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let model = results[indexPath.row]
    delegate?.searchResultsViewControllerDidSelect(searchResult: model)
  }
}
