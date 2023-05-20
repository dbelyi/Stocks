//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import SafariServices
import UIKit

// MARK: - StockDetailsViewController

class StockDetailsViewController: UIViewController {
  // MARK: - Lifecycle

  init(symbol: String, companyName: String, candleStickData: [CandleStick] = []) {
    self.symbol = symbol
    self.companyName = companyName
    self.candleStickData = candleStickData
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: - Internal

  /// This method is called when the view controller's view is loaded into memory.
  /// It sets the background color of the view, sets the title of the view controller,
  /// sets up a close button, sets up a table view, and fetches financial data and news.
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    title = companyName
    setUpCloseButton()
    setUpTable()
    fetchFinancialData()
    fetchNews()
  }

  /// This method is called when the view controller's view is laid out, which happens
  /// after the view is loaded into memory and any time the view's bounds change. It sets
  /// the frame of the table view to be the same as the view's bounds.
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }

  /// This method is called when the user taps a button to close the view. It dismisses
  /// the view controller and any presented view controllers.
  @objc
  func didTapClose() {
    dismiss(animated: true, completion: nil)
  }

  // MARK: - Private

  /// This property is a string that represents the stock symbol for the financial data being displayed.
  private let symbol: String

  /// This property is a string that represents the name of the company for the financial data being displayed.
  private let companyName: String

  /// This property is an array of CandleStick objects that represent financial data for a stock.
  private var candleStickData = [CandleStick]()

  /// This property is an array of NewsStory objects that represent news stories related to the stock.
  private var stories = [NewsStory]()

  /// This property is an optional Metrics object that represents performance metrics for the stock.
  private var metrics: Metrics?

  /// This property is a UITableView object that displays the news stories related to the stock.
  private let tableView: UITableView = {
    let table = UITableView()
    table.register(
      NewsHeaderView.self,
      forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier
    )
    table.register(
      NewsStoryTableViewCell.self,
      forCellReuseIdentifier: NewsStoryTableViewCell.identifier
    )
    return table
  }()

  /// This method is called when the view controller's view is loaded into memory. It adds the
  /// table view to the view hierarchy, sets the table view's delegate and data source to the
  /// view controller, and sets the table view's header view to a custom view.
  private func setUpTable() {
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
    tableView
      .tableHeaderView =
      UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100))
  }

  /// This method is called to fetch financial data for a stock from an API. It uses a dispatch group to
  /// wait for multiple API calls to complete before rendering the chart. If there is no existing data
  /// for the stock, it fetches candlestick data and stores it in the candleStickData property. It also
  /// fetches financial metrics for the stock and stores them in the metrics property. Once both API calls
  /// have completed, it calls the renderChart() method to display the financial data.
  private func fetchFinancialData() {
    let group = DispatchGroup()

    if candleStickData.isEmpty {
      group.enter()
      APICaller.shared().marketData(for: symbol) { [weak self] result in
        defer {
          group.leave()
        }
        switch result {
        case let .success(response):
          self?.candleStickData = response.candleSticks
        case let .failure(error):
          print(error)
        }
      }
    }

    group.enter()
    APICaller.shared().financialMetrics(for: symbol) { [weak self] result in
      defer {
        group.leave()
      }
      switch result {
      case let .success(response):
        let metrics = response.metric
        self?.metrics = metrics
      case let .failure(error):
        print(error)
      }
    }
    group.notify(queue: .main) { [weak self] in
      self?.renderChart()
    }
  }

  /// This method is called to render a chart displaying financial data for a stock. It creates a custom header
  /// view for the table view, generates view models for the financial metrics, and configures the header view
  /// with the chart data and financial metrics. Finally, it sets the table view's header view to the custom header view.
  private func renderChart() {
    let headerView =
      StockDetailHeaderView(frame: CGRect(
        x: 0,
        y: 0,
        width: view.width,
        height: (view.width * 0.7) + 100
      ))

    var viewModels = [MetricCollectionViewCell.ViewModel]()
    if let metrics = metrics {
      viewModels.append(.init(name: "52W High", value: "\(metrics.AnnualWeekHigh)"))
      viewModels.append(.init(name: "52L High", value: "\(metrics.AnnualWeekLow)"))
      viewModels.append(.init(name: "52W Return", value: "\(metrics.AnnualWeekPriceReturnDaily)"))
      viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
      viewModels.append(.init(name: "10D Vol.", value: "\(metrics.TenDayAverageTradingVolume)"))
    }

    let change = getChangePersentage(symbol: symbol, for: candleStickData)
    headerView.configure(
      chartViewModel: .init(
        data: candleStickData.reversed().map { $0.close },
        showLegend: true,
        showAxis: true,
        fillColor: change < 0 ? .systemRed : .systemGreen
      ),
      metricViewModels: viewModels
    )

    tableView.tableHeaderView = headerView
  }

  /// This method is called to fetch news stories related to a stock from an API. It updates the stories
  /// property with the stories returned from the API and reloads the table view on the main thread.
  private func fetchNews() {
    APICaller.shared().news(for: .company(symbol: symbol)) { [weak self] result in
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

  /// This method is called to set up a close button in the navigation bar of the view controller.
  /// When the user taps the close button, it calls the didTapClose() method to dismiss the view controller.
  private func setUpCloseButton() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .close,
      target: self,
      action: #selector(didTapClose)
    )
  }

  /// This method is called to calculate the percentage change between the latest close price and the prior close price for a stock.
  ///
  /// - Parameters:
  ///   - symbol: `String` representing the stock symbol
  ///   - data: `Array` of `CandleStick` objects representing financial data for the stock.
  /// - Returns: `Double` value representing the percentage change between the latest close price and the prior close price for a stock.
  private func getChangePersentage(symbol: String, for data: [CandleStick]) -> Double {
    let latestDate = data[0].date
    guard let latestClose = data.first?.close, let priorClose = data.first(where: {
      !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
    })?.close else { return 0 }

    let diff = 1 - (priorClose / latestClose)

    return diff
  }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource {
  /// This method is used to specify the number of rows that should be displayed in a section of a `UITableView`. It returns an integer value that represents the number of rows that should be displayed in the specified section.
  ///
  /// - Parameters:
  ///   - tableView: The UITableView object that is requesting the number of rows.
  ///   - section: An integer value that represents the section for which the number of rows is being requested.
  /// - Returns: An integer value that represents the number of rows in the specified section.
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return stories.count
  }

  /// This method is used to create and configure cells for the UITableView. It returns a UITableViewCell object that represents a cell in the UITableView.
  ///
  /// - Parameters:
  ///   - tableView: The UITableView object that is requesting the cell.
  ///   - indexPath: An IndexPath object that represents the location of the cell in the UITableView.
  /// - Returns: A UITableViewCell object that represents a cell in the UITableView.
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: NewsStoryTableViewCell.identifier,
      for: indexPath
    ) as? NewsStoryTableViewCell else {
      fatalError()
    }

    cell.configure(with: .init(model: stories[indexPath.row]))
    return cell
  }

  /// This method is used to specify the height of a row in the `UITableView`. It returns a `CGFloat` value that represents the height of the row.
  ///
  /// - Parameters:
  ///   - tableView: The UITableView object that is requesting the row height.
  ///   - indexPath: An `IndexPath` object that represents the location of the row in the `UITableView`.
  /// - Returns: A `CGFloat` value that represents the height of the row.
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return NewsStoryTableViewCell.preferredHeight
  }

  /// This method is used to specify the view that should be displayed as the header for a section in the `UITableView`.
  ///
  /// - Parameters:
  ///   - tableView: The `UITableView` object that is requesting the header view.
  ///   - section: An integer value that represents the section for which the header view is being requested.
  /// - Returns: A `UIView` object that represents the header view for the section.
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let header = tableView
      .dequeueReusableHeaderFooterView(
        withIdentifier: NewsHeaderView
          .identifier
      ) as? NewsHeaderView else {
      return nil
    }
    header.delegate = self
    header.configure(with: .init(
      title: symbol.uppercased(),
      shouldShowAddButton: !PersistenceManager.shared.watchlistContains(symbol: symbol)
    ))
    return header
  }

  /// This method is used to specify the height of the header view for a section in the `UITableView`.
  ///
  /// - Parameters:
  ///   - tableView: The `UITableView` object that is requesting the height of the header view.
  ///   - section: An integer value that represents the section for which the height of the header view is being requested.
  /// - Returns: A `CGFloat` value that represents the height of the header view for the section.
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return NewsHeaderView.prefferedHeight
  }

  /// This method is called when a row in the `UITableView` is selected.
  /// It is used to handle actions that should be taken when a row is selected.
  ///
  /// - Parameters:
  ///   - tableView: The UITableView object that is being interacted with.
  ///   - indexPath: An IndexPath object that represents the location of the selected row in the UITableView.
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let url = URL(string: stories[indexPath.row].url) else { return }
    let vc = SFSafariViewController(url: url)
    present(vc, animated: true)
  }
}

// MARK: NewsHeaderViewDelegate

extension StockDetailsViewController: NewsHeaderViewDelegate {
  /// This method is triggered when the user taps the "Add" button in a news header view. It adds the corresponding
  /// stock symbol and company name to the user's watchlist and displays an alert to confirm that the stock has been added.
  ///
  /// - Parameter headerView: The news header view object that triggered the method.
  func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
    headerView.button.isHidden = true
    PersistenceManager.shared.addToWatchlist(symbol: symbol, companyName: companyName)
    let alert = UIAlertController(
      title: "Added to Watchlist",
      message: "We've added \(companyName) to your wathlist.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
    present(alert, animated: true)
  }
}
