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

  /// This property is a static variable of type `CGFloat` that is used to determine the maximum width of a label that displays the change percentage of a stock.
  /// This property is used to help format the label so that it aligns properly with other labels in the table view cell.
  static var maxChangeWidth: CGFloat = 0

  /// This method is an overridden method in a view controller that is called when the view of the view controller is loaded into memory.
  /// This method is responsible for setting up the initial state of the view controller, including adding subviews, setting up data sources, and fetching data.
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

  /// This method is an overridden method in a view controller that is called every time the view of the view controller is laid out.
  /// This method is responsible for adjusting the frame of a `UITableView` to make sure it takes up the full bounds of the view controller's view.
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }

  // MARK: - Private

  /// This property is a private optional `Timer` variable that is used to control the delay before initiating a search operation.
  /// If the user continues to type before the timer is finished, it will invalidate the current timer and start a new one.
  private var searchTimer: Timer?

  /// This property is a private optional `FloatingPanelController` variable that is used to manage the floating panel that is displayed on the view controller.
  private var floatingPanelController: FloatingPanelController?

  /// This property is a private dictionary variable that is used to store an array of `CandleStick` objects associated with each stock symbol. The keys of the dictionary are the stock symbols.
  private var watchlistMap: [String: [CandleStick]] = [:]

  /// This property is a private array variable that is used to store an array of `WatchListTableViewCell.ViewModel` objects.
  /// These view models are used to populate the cells of the table view displayed on the view controller.
  private var viewModels: [WatchListTableViewCell.ViewModel] = []

  /// This property is a private optional `NSObjectProtocol` variable that is used to observe changes in watchlist data.
  /// When the observer is set up, it will call a specified method in the view controller whenever the watchlist data changes.
  private var observer: NSObjectProtocol?

  /// This property is a private constant `UITableView` variable that is used to display a table view on the view controller.
  /// The table view is set up with a registered `WatchListTableViewCell` class and identifier.
  private let tableView: UITableView = {
    let table = UITableView()
    table.register(
      WatchListTableViewCell.self,
      forCellReuseIdentifier: WatchListTableViewCell.identifier
    )
    return table
  }()

  /// This method is a private method that is used to set up a `UITableView` within a view controller.
  /// This method is responsible for adding the `UITableView` as a subview of the view controller's view
  /// and setting its delegate and data source to the view controller itself.
  private func setUpTableView() {
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }

  /// This method is responsible for fetching data for the watchlist symbols stored in `PersistenceManager`.
  /// It uses `APICaller` to fetch market data for each symbol and updates the `watchlistMap` with the `candlestick` data for each symbol.
  /// This method uses `DispatchGroup` to wait for all API calls to complete before creating view models and reloading the table view.
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

  /// This method is responsible for creating an array of view models for each symbol in the watchlistMap.
  /// It uses helper methods to calculate the latest closing price and percentage change for each symbol.
  /// It also creates a chart view model to display the candlestick data for each symbol.
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
          showAxis: false,
          fillColor: changePercentage < 0 ? .systemRed : .systemGreen
        )
      ))
    }

    self.viewModels = viewModels
  }

  /// This method is a helper method that is responsible for calculating the latest closing price for a symbol using its candlestick data.
  ///
  /// - Parameter data: An array of `CandleStick` objects representing the historical data for a symbol.
  /// - Returns: A formatted string representing the latest closing price for the symbol, with two decimal places.
  private func getLatestClosingPrice(from data: [CandleStick]) -> String {
    guard let closingPrice = data.first?.close else { return "" }
    return .formatted(number: closingPrice)
  }

  /// This method is a helper method that is responsible for calculating the percentage change for a symbol using its candlestick data.
  ///
  /// - Parameters:
  ///   - symbol: A string representing the symbol of the company.
  ///   - data: An array of `CandleStick` objects representing the historical data for the symbol.
  /// - Returns: A double value representing the percentage change for the symbol.
  private func getChangePersentage(symbol: String, for data: [CandleStick]) -> Double {
    let latestDate = data[0].date
    guard let latestClose = data.first?.close, let priorClose = data.first(where: {
      !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
    })?.close else { return 0 }

    let diff = 1 - (priorClose / latestClose)

    return diff
  }

  /// This method is responsible for setting up a floating panel to display news stories.
  /// It creates a `NewsViewController` object with a specified type, creates a `FloatingPanelController`
  /// object with self as the delegate, and sets the content view controller to the `NewsViewController`.
  /// It also sets the background color of the surface view, adds the panel to the parent view controller,
  /// tracks the table view for scrolling, and sets the corner radius and clips to bounds for the surface view.
  private func setUpFloatingPanel() {
    let vc = NewsViewController(type: .topStories)
    let floatingPanelController = FloatingPanelController(delegate: self)
    floatingPanelController.surfaceView.backgroundColor = .secondarySystemBackground
    floatingPanelController.set(contentViewController: vc)
    floatingPanelController.addPanel(toParent: self)
    floatingPanelController.track(scrollView: vc.tableView)
    floatingPanelController.surfaceView.layer.cornerRadius = 6.0
    floatingPanelController.surfaceView.clipsToBounds = true
    self.floatingPanelController = floatingPanelController
  }

  /// This method is responsible for setting up the title view of the navigation bar.
  /// It creates a `UIView` object with a specified frame, creates a `UILabel` object with
  /// a specified frame and text, sets the font of the label, adds the label to the title
  /// view, and sets the title view of the navigation item to the title view.
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

  /// This method is responsible for setting up the search controller for the navigation bar.
  /// It creates a `SearchResultsViewController` object, sets its delegate to self, creates a
  /// `UISearchController` object with the `SearchResultsViewController` as the search results
  /// view controller, sets the search results updater to self, and sets the navigation item's
  /// search controller to the search controller.
  private func setUpSearchController() {
    let searchResultsViewController = SearchResultsViewController()
    searchResultsViewController.delegate = self

    let searchController = UISearchController(searchResultsController: searchResultsViewController)
    searchController.searchResultsUpdater = self

    navigationItem.searchController = searchController
  }

  /// This method sets up an observer to listen for a notification. When the notification is
  /// received, it removes all view models, fetches watchlist data again, and updates the UI.
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
  /// This method is responsible for updating the search results for a search bar.
  /// It gets the search query from the search bar, validates it, resets the search
  /// timer, and kicks off a new timer to search for the query using the `APICaller`
  /// class. When the search result is returned, it updates the search results view
  /// controller with the response.
  ///
  /// - Parameter searchController: A UISearchController object representing the
  /// search controller for the navigation bar.
  func updateSearchResults(for searchController: UISearchController) {
    guard let query = searchController.searchBar.text,
          let searchResultsVC = searchController
          .searchResultsController as? SearchResultsViewController,
          !query.trimmingCharacters(in: .whitespaces).isEmpty else {
      return
    }

    searchTimer?.invalidate()

    searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
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
  /// This method is called when the user selects a search result in a search view controller.
  /// The method resigns the first responder status of the search bar, creates a new
  /// `StockDetailsViewController` instance, sets its properties using the selected SearchResult
  /// object, creates a new `UINavigationController` instance with the `StockDetailsViewController`
  /// instance as its root view controller, sets the title of the `StockDetailsViewController` to
  /// the selected SearchResult description, and presents the navigation controller modally.
  ///
  /// - Parameter searchResult: A SearchResult object that represents the selected search result.
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
  /// This method is called by a `FloatingPanelController` whenever its state changes.
  /// The method hides or shows the navigation item's title view based on whether the floating panel state is .full or not.
  ///
  /// - Parameter fpc: A `FloatingPanelController` object that represents the floating panel whose state has changed.
  func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
    navigationItem.titleView?.isHidden = fpc.state == .full
  }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
  /// This method is a built-in method of the `UITableViewDataSource` protocol in iOS.
  /// This method is called by a table view object to determine the number of rows to
  /// be displayed in a particular section of the table view.
  ///
  /// - Parameters:
  ///   - tableView: The table view requesting this information.
  ///   - section: An index number identifying a section of the table view.
  /// - Returns: An integer value indicating the number of rows in the specified section.
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModels.count
  }

  /// This method is a built-in method of the `UITableViewDataSource` protocol in iOS.
  /// It is called by the table view object to retrieve the cell for a particular row
  /// in a given section of the table view.
  ///
  /// - Parameters:
  ///   - tableView: The table view requesting this information.
  ///   - indexPath: An index path locating a row in tableView.
  /// - Returns: A UITableViewCell object representing the row at the specified index path.
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: WatchListTableViewCell.identifier,
      for: indexPath
    ) as? WatchListTableViewCell else { fatalError() }
    cell.delegate = self
    cell.configure(with: viewModels[indexPath.row])
    return cell
  }

  /// This method is a built-in method of the `UITableViewDelegate` protocol in iOS.
  /// This method is called by the table view object to determine the height of a row
  /// at a specific index path.
  ///
  /// - Parameters:
  ///   - tableView: The table view requesting this information.
  ///   - indexPath: An index path locating a row in tableView.
  /// - Returns: A `CGFloat` value representing the height of the row at the specified index path.
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return WatchListTableViewCell.prefferedHeight
  }

  /// This method is a delegate method from the `UITableViewDelegate` protocol that gets called whenever a user selects a row in a `UITableView`. This method is used to provide custom behavior when a row is selected.
  ///
  /// - Parameters:
  ///   - tableView: The UITableView instance that the user interacted with.
  ///   - indexPath: The IndexPath of the selected row.
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

  /// This is a method of the `UITableViewDelegate` protocol that determines whether a row at a specified index path can be edited.
  ///
  /// - Parameters:
  ///   - tableView: The table view requesting this information.
  ///   - indexPath: The index path of the row being edited.
  /// - Returns: A Boolean value indicating whether the row specified at the index path can be edited.When the value is true, the row can be edited. When the value is false, the row cannot be edited.
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  /// This is a method of the `UITableViewDelegate` protocol that specifies the editing style for a row at a specified index path.
  ///
  /// - Parameters:
  ///   - tableView: The table view requesting this information.
  ///   - indexPath: The index path of the row for which to return the editing style.
  func tableView(
    _ tableView: UITableView,
    editingStyleForRowAt indexPath: IndexPath
  )
    -> UITableViewCell.EditingStyle {
    return .delete
  }

  /// This is a method of the `UITableViewDelegate` protocol that handles row deletion and other editing operations.
  ///
  /// - Parameters:
  ///   - tableView: The table view requesting this information.
  ///   - editingStyle: The editing style associated with the row at the specified index path.
  ///   - indexPath: The index path of the row being edited.
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
  /// This method is a function that is called when the maximum width of a label that displays the change percentage of a stock in a table view cell has been updated.
  /// This method is responsible for reloading the table view to apply the updated formatting of the label.
  func didUpdateMaxWidth() {
    // MARK: - TODO: Only refresh rows prior to the current row that changes to max width

    tableView.reloadData()
  }
}
