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

  /// This method updates the results displayed in the view controller.
  /// - Parameter results: An array of SearchResult objects representing the results to display.
  public func update(with results: [SearchResult]) {
    self.results = results
    updateTableView()
  }

  // MARK: - Internal

  /// This property is a weak reference to the delegate object that conforms to the `SearchResultsViewControllerDelegate` protocol.
  weak var delegate: SearchResultsViewControllerDelegate?

  /// This method is called after the view controller has loaded its view hierarchy into memory. It sets up the view controller's view and initializes its table view.
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setUpTable()
  }

  /// This method is called when the view controller's view has been laid out. It sets the table view's frame to match the bounds of the view controller's view.
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }

  // MARK: - Private

  /// This is a private property that represents the table view displayed in the view controller. It is initialized as a new `UITableView` instance, and its properties are configured to prepare it for use in the view controller
  private let tableView: UITableView = {
    let table = UITableView()
    table.register(
      SearchResultTableViewCell.self,
      forCellReuseIdentifier: SearchResultTableViewCell.identifier
    )
    table.isHidden = true
    return table
  }()

  /// This is a private property that represents the search results displayed in the table view. It is an array of `SearchResult` objects, and it is initialized as an empty array. When this property is set, the `updateTableView()` method is called to update the table view with the new data.
  private var results: [SearchResult] = [] {
    didSet {
      updateTableView()
    }
  }

  /// This is a private method that updates the table view with the current search results. It reloads the table view data and sets its isHidden property based on whether there are any search results to display
  private func updateTableView() {
    tableView.reloadData()
    tableView.isHidden = results.isEmpty
  }

  /// This is a private method that sets up the table view for use in the view controller. It adds the table view as a subview of the view controller's view, and sets its delegate and dataSource properties to the view controller.
  private func setUpTable() {
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
  /// This method returns the number of rows in a given section of a table view.
  ///
  /// - Parameters:
  ///   - tableView: The table view object requesting this information
  ///   - section: An integer value that represents the section index.
  /// - Returns: An integer value that represents the number of rows in a given section.
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results.count
  }

  /// This method returns a table view cell object for the specified row and section.
  ///
  /// - Parameters:
  ///   - tableView: The table view object requesting this information.
  ///   - indexPath: An index path locating a row in the table view.
  /// - Returns: A table view cell object that represents the cell for the specified row and section.
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

  /// This method is called when a row in the table view is selected
  ///
  /// - Parameters:
  ///   - tableView: The table view object requesting this information.
  ///   - indexPath: An index path locating the selected row in the table view.
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let model = results[indexPath.row]
    delegate?.searchResultsViewControllerDidSelect(searchResult: model)
  }
}
