//
//  ViewController.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import FloatingPanel
import UIKit

// MARK: - WatchListViewController

class WatchListViewController: UIViewController {
  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    setUpSearchController()
    setUpFloatingPanel()
    setUpTitleView()
  }

  // MARK: Private

  private var searchTimer: Timer?

  private var floatingPanelController: FloatingPanelController?

  private func setUpFloatingPanel() {
    let vc = NewsViewController(type: .topStories)
    let floatingPanelController = FloatingPanelController(delegate: self)
    floatingPanelController.surfaceView.backgroundColor = .secondarySystemBackground
    floatingPanelController.set(contentViewController: vc)
    floatingPanelController.addPanel(toParent: self)
    floatingPanelController.track(scrollView: vc.tableView)
    self.floatingPanelController = floatingPanelController
  }

  private func setUpTitleView() {
    let titleView = UIView(frame: CGRect(
      x: 0,
      y: 0,
      width: view.width,
      height: navigationController?.navigationBar.height ?? 100
    ))

    let label = UILabel(frame: CGRect(
      x: 0,
      y: 0,
      width: titleView.width - 20,
      height: titleView.height
    ))

    label.text = "Stocks"
    label.font = .systemFont(ofSize: 40, weight: .medium)
    titleView.addSubview(label)

    navigationItem.titleView = titleView
  }

  private func setUpSearchController() {
    let searchResultsViewController = SearchResultsViewController()
    searchResultsViewController.delegate = self

    let searchController = UISearchController(searchResultsController: searchResultsViewController)
    searchController.searchResultsUpdater = self

    navigationItem.searchController = searchController
  }
}

// MARK: UISearchResultsUpdating

extension WatchListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let query = searchController.searchBar.text,
          let searchResultsVC = searchController
          .searchResultsController as? SearchResultsViewController,
          !query.trimmingCharacters(in: .whitespaces).isEmpty else {
      return
    }

    /// Reset timer
    searchTimer?.invalidate()

    /// Kick off new timer
    /// Optimize to reduce number of searches for when user stops typing
    searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
      /// Call API to search
      APICaller.shared().search(query: query) { result in
        switch result {
        case let .success(response):
          DispatchQueue.main.async {
            searchResultsVC.update(with: response.result)
          }
        case let .failure(error):
          DispatchQueue.main.async {
            searchResultsVC.update(with: [])
          }
          print(error)
        }
      }
    })
  }
}

// MARK: SearchResultsViewControllerDelegate

extension WatchListViewController: SearchResultsViewControllerDelegate {
  func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
    navigationItem.searchController?.searchBar.resignFirstResponder()

    let stockDetailsVC = StockDetailsViewController()
    let navigationController = UINavigationController(rootViewController: stockDetailsVC)
    stockDetailsVC.title = searchResult.description

    present(navigationController, animated: true)
  }
}

// MARK: FloatingPanelControllerDelegate

extension WatchListViewController: FloatingPanelControllerDelegate {
  func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
    navigationItem.titleView?.isHidden = fpc.state == .full
  }
}
