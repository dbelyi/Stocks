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

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    title = companyName
    setUpCloseButton()
    setUpTable()
    fetchFinancialData()
    fetchNews()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }

  @objc
  func didTapClose() {
    dismiss(animated: true, completion: nil)
  }

  // MARK: - Private

  private let symbol: String

  private let companyName: String

  private var candleStickData: [CandleStick]

  private var stories = [NewsStory]()

  private var metrics: Metrics?

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

  private func setUpTable() {
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
    tableView
      .tableHeaderView =
      UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100))
  }

  private func fetchFinancialData() {
    let group = DispatchGroup()

    if candleStickData.isEmpty {
      group.enter()
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
      viewModels.append(.init(name: "Beya", value: "\(metrics.beta)"))
      viewModels.append(.init(name: "10D Vol.", value: "\(metrics.TenDayAverageTradingVolume)"))
    }

    headerView.configure(
      chartViewModel: .init(data: [], showLegend: false, showAxis: false),
      metricViewModels: viewModels
    )

    tableView.tableHeaderView = headerView
  }

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

  private func setUpCloseButton() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .close,
      target: self,
      action: #selector(didTapClose)
    )
  }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return stories.count
  }

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

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return NewsStoryTableViewCell.preferredHeight
  }

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

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return NewsHeaderView.prefferedHeight
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let url = URL(string: stories[indexPath.row].url) else { return }
    let vc = SFSafariViewController(url: url)
    present(vc, animated: true)
  }
}

// MARK: NewsHeaderViewDelegate

extension StockDetailsViewController: NewsHeaderViewDelegate {
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
