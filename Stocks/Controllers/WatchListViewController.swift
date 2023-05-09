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
  // MARK: - Internal

  static var maxChangeWidth: CGFloat = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    setUpSearchController()
    setUpTableView()
    fetchWatchlistData()
    setUpFloatingPanel()
    setUpTitleView()
    setUpObserver()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }

  // MARK: - Private

  private var searchTimer: Timer?

  private var floatingPanelController: FloatingPanelController?

  private var watchlistMap: [String: [CandleStick]] = [:]

  private var viewModels: [WatchListTableViewCell.ViewModel] = []

  private var observer: NSObjectProtocol?

  private let tableView: UITableView = {
    let table = UITableView()
    table.register(
      WatchListTableViewCell.self,
      forCellReuseIdentifier: WatchListTableViewCell.identifier
    )
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

    for symbol in symbols where watchlistMap[symbol] == nil {
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
        changePercentage: .percentage(from: changePercentage),
        chartViewModel: .init(
          data: candelSticks.reversed().map { $0.close },
          showLegend: false,
          showAxis: false
        )
      ))
    }

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

  private func setUpObserver() {
    observer = NotificationCenter.default.addObserver(
      forName: .didAddToWatchList,
      object: nil,
      queue: .main,
      using: { [weak self] _ in
        self?.viewModels.removeAll()
        self?.fetchWatchlistData()
      }
    )
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

    let stockDetailsVC = StockDetailsViewController(
      symbol: searchResult.displaySymbol,
      companyName: searchResult.description
    )
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
    return viewModels.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: WatchListTableViewCell.identifier,
      for: indexPath
    ) as? WatchListTableViewCell else { fatalError() }
    cell.delegate = self
    cell.configure(with: viewModels[indexPath.row])
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return WatchListTableViewCell.prefferedHeight
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let viewModel = viewModels[indexPath.row]
    let stockDetailsVC = StockDetailsViewController(
      symbol: viewModel.symbol,
      companyName: viewModel.companyName,
      candleStickData: watchlistMap[viewModel.symbol] ?? []
    )
    let navigationController = UINavigationController(rootViewController: stockDetailsVC)
    present(navigationController, animated: true)
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(
    _ tableView: UITableView,
    editingStyleForRowAt indexPath: IndexPath
  )
    -> UITableViewCell.EditingStyle {
    return .delete
  }

  func tableView(
    _ tableView: UITableView,
    commit editingStyle: UITableViewCell.EditingStyle,
    forRowAt indexPath: IndexPath
  ) {
    if editingStyle == .delete {
      tableView.beginUpdates()

      PersistenceManager.shared.removeFromWatchlist(symbol: viewModels[indexPath.row].symbol)

      viewModels.remove(at: indexPath.row)

      tableView.deleteRows(at: [indexPath], with: .automatic)

      tableView.endUpdates()
    }
  }
}

// MARK: WatchListTableViewCellDelegate

extension WatchListViewController: WatchListTableViewCellDelegate {
  func didUpdateMaxWidth() {
    // MARK: - TODO: Only refresh rows prior to the current row that changes to max width

    tableView.reloadData()
  }
}
