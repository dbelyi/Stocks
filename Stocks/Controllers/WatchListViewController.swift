//
//  ViewController.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import UIKit

// MARK: - WatchListViewController

class WatchListViewController: UIViewController {
  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setUpSearchController()
  }

  // MARK: Private

  private func setUpSearchController() {
    let resultVC = SearchResultsViewController()
    let searchVC = UISearchController(searchResultsController: resultVC)
    searchVC.searchResultsUpdater = self
    navigationItem.searchController = searchVC
  }
}

// MARK: UISearchResultsUpdating

extension WatchListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let query = searchController.searchBar.text,
          let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
          !query.trimmingCharacters(in: .whitespaces).isEmpty else {
      return
    }

    // MARK: - TODO: Call API to search

    // MARK: - TODO: Optimize to reduce number of searches for when user stops typing

    // MARK: - TODO: Update results controller
  }
}
