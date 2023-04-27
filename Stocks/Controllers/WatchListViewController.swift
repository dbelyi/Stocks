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
    setUpTableView()
    fetchWatchlistData()
    setUpFloatingPanel()
    setUpTitleView()
  }

  // MARK: Private

  private var searchTimer: Timer?

  private var floatingPanelController: FloatingPanelController?

  private var watchlistMap: [String: [CandleStick]] = [:]

  private var viewModels: [WatchListTableViewCell.ViewModel] = []

  private let tableView: UITableView = {
    let table = UITableView()

    return table
  }()

  private func setUpTableView() {
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }

  private func fetchWatchlistData() {
    let symbols = PersistenceManager.shared.watchlist

    let group = DispatchGroup()

    for symbol in symbols {
      group.enter()

      APICaller.shared().marketData(for: symbol) { [weak self] result in
        defer {
          group.leave()
        }

        switch result {
        case let .success(data):
          let candleSticks = data.candleSticks
          self?.watchlistMap[symbol] = candleSticks
        case let .failure(error):
          print(error)
        }
      }
    }

    group.notify(queue: .main) { [weak self] in
      self?.createViewModels()
      self?.tableView.reloadData()
    }

    tableView.reloadData()
  }

  private func createViewModels() {
    var viewModels = [WatchListTableViewCell.ViewModel]()

    for (symbol, candelSticks) in watchlistMap {
      let changePercentage = getChangePersentage(symbol: symbol, for: candelSticks)
      viewModels.append(.init(
        symbol: symbol,
        companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
        price: getLatestClosingPrice(from: candelSticks),
        changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
        changePercentage: .percentage(from: changePercentage)
      ))
    }

    print("\n\n\(viewModels)\n\n")

    self.viewModels = viewModels
  }

  private func getLatestClosingPrice(from data: [CandleStick]) -> String {
    guard let closingPrice = data.first?.close else { return "" }
    return .formatted(number: closingPrice)
  }

  private func getChangePersentage(symbol: String, for data: [CandleStick]) -> Double {
    let latestDate = data[0].date
    guard let latestClose = data.first?.close, let priorClose = data.first(where: {
      !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
    })?.close else { return 0 }

    let diff = 1 - (priorClose / latestClose)

    return diff
  }

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

// MARK: UITableViewDelegate, UITableViewDataSource

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return watchlistMap.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    // MARK: - Open details for selection
  }
}
