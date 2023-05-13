//
//  TopStoriesNewsViewController.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import SafariServices
import UIKit

// MARK: - NewsViewController

class NewsViewController: UIViewController {
  // MARK: - Lifecycle

  init(type: Type) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  // MARK: - Internal

  /// This enum is defined with two cases, `topStories` and `company`. The `title` property is a
  /// computed property of the Type enum that returns a string representing the title of the enum case.
  enum `Type` {
    case topStories
    case company(symbol: String)

    // MARK: - Internal

    var title: String {
      switch self {
      case .topStories:
        return "Top Stories"
      case let .company(symbol):
        return symbol.uppercased()
      }
    }
  }

  /// This property is an instance of the `UITableView` class that is created using a closure.
  /// The closure sets some properties of the table view, including registering a cell and header
  /// view, setting the background color to clear, and returning the table view.
  let tableView: UITableView = {
    let table = UITableView()
    table.register(
      NewsStoryTableViewCell.self,
      forCellReuseIdentifier: NewsStoryTableViewCell.identifier
    )
    table.register(
      NewsHeaderView.self,
      forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier
    )
    table.backgroundColor = .clear
    return table
  }()

  /// This method is a lifecycle method of a view controller that is called after the view controller's
  /// view has been loaded into memory. This method is used to set up and configure the view controller's view.
  /// In this example, the `setUpTable` method and `fetchNews` method are called to set up the table view and
  /// fetch news stories.
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpTable()
    fetchNews()
  }

  /// This method is a lifecycle method of a view controller that is called after the view controller's
  /// view has been laid out. This method is used to adjust the layout of the view controller's subviews to
  /// fit the size of the view. In this example, the tableView frame is set to the bounds of the view to ensure
  /// that the table view fills the entire screen.
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }

  // MARK: - Private

  /// This property is a private instance variable of the class. It is of type Type and it is used to store
  /// the type of news that the user wants to fetch.
  private let type: Type

  /// This property is a private instance variable of the class. It is an array of `NewsStory` objects and
  /// it is used to store the news stories that are fetched from the API.
  private var stories = [NewsStory]()

  /// This method is used to set up the tableView in the view. It adds the tableView as a subview to the
  /// current view, sets the delegate and data source of the tableView.
  private func setUpTable() {
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }

  /// This method is used to fetch news stories from the API. It calls the news(for: type) method of the APICaller
  /// class and passes in the type property as a parameter. It then handles the result of the API call
  /// by either updating the stories property and reloading the tableView or printing out the error message.
  private func fetchNews() {
    APICaller.shared().news(for: type) { [weak self] result in
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

  /// This method is used to open a URL in a `SFSafariViewController`.
  /// It creates a new instance of `SFSafariViewController` with the given URL and presents it modally.
  private func open(url: URL) {
    let safariVC = SFSafariViewController(url: url)
    present(safariVC, animated: true)
  }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
  /// This method returns the number of rows in a given section of a table view.
  ///
  /// - Parameters:
  ///   - tableView: The table view object requesting this information.
  ///   - section: An integer value that represents the section index.
  /// - Returns: An integer value that represents the number of rows in a given section.
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return stories.count
  }

  /// This method returns a table view cell object for the specified row and section.
  ///
  /// - Parameters:
  ///   - tableView: The table view object requesting this information.
  ///   - indexPath: An index path locating a row in the table view.
  /// - Returns: A table view cell object that represents the cell for the specified row and section.
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: NewsStoryTableViewCell.identifier,
      for: indexPath
    ) as? NewsStoryTableViewCell else { fatalError() }
    cell.configure(with: .init(model: stories[indexPath.row]))
    return cell
  }

  /// This method returns a view object to display in the header of the specified section of the table view.
  ///
  /// - Parameters:
  ///   - tableView: The table view object requesting this information.
  ///   - section: An integer value that represents the section index.
  /// - Returns: A view object that represents the header of the specified section of the table view, or nil if the section has no header view.
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let header = tableView
      .dequeueReusableHeaderFooterView(
        withIdentifier: NewsHeaderView
          .identifier
      ) as? NewsHeaderView else { return nil }
    header.configure(with: .init(title: type.title, shouldShowAddButton: false))
    return header
  }

  /// This method returns the height of a row in a given section of a table view.
  ///
  /// - Parameters:
  ///   - tableView: The table view object requesting this information.
  ///   - indexPath: An index path locating a row in the table view.
  /// - Returns: A `CGFloat` value that represents the height of the row at the specified index path.
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return NewsStoryTableViewCell.preferredHeight
  }

  /// This method returns the height of the header view for the specified section of the table view.
  ///
  /// - Parameters:
  ///   - tableView: The table view object requesting this information.
  ///   - section: An integer value that represents the section index.
  /// - Returns: A CGFloat value that represents the height of the header view for the specified section.
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return NewsHeaderView.prefferedHeight
  }

  /// This method is called when a row in the table view is selected.
  /// - Parameters:
  ///   - tableView: The table view object requesting this information.
  ///   - indexPath: An index path locating the selected row in the table view.
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let story = stories[indexPath.row]
    guard let url = URL(string: story.url) else {
      presentFailedToOpenAlert()
      return
    }
    open(url: url)
  }

  /// This is a private method that presents an alert to the user when the app is unable to open an article. It takes no parameters.
  private func presentFailedToOpenAlert() {
    let alert = UIAlertController(
      title: "Unable to Open",
      message: "We were unable to open the article.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "Dissmis", style: .cancel))
    present(alert, animated: true)
  }
}
