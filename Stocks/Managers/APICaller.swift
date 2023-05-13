//
//  APICaller.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import Foundation

final class APICaller {
  // MARK: - Lifecycle

  private init() {}

  // MARK: - Public

  /// This method is a public function that searches for information using a specified query and returns a response in a completion handler.
  /// This method is used to search for data from an API.
  ///
  /// - Parameters:
  ///   - query: The query string to search for.
  ///   - completion: A closure that is called when the search has completed. This closure takes a `Result` object with a `SearchResponse` object on success and an `Error` object on failure.
  public func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> ()) {
    guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    else { return }
    makeAPIRequest(
      url: url(for: .search, queryParams: ["q": safeQuery]),
      expecting: SearchResponse.self,
      completion: completion
    )
  }

  /// Fetch news stories for the given type.
  ///
  /// - Parameters:
  ///   - type: The type of news stories to fetch.
  ///   - completion: A closure that will be called with the news stories, or an error if the request failed.
  ///

  /// This method is a public function that retrieves news stories from an API for a specified type and returns a response in a completion handler.
  /// This method is used to get news stories from an API. It takes a type parameter and a completion handler closure as parameters.
  ///
  /// - Parameters:
  ///   - type: The type of news stories to retrieve. This is an enum value of type `NewsViewController.Type`.
  ///   - completion: A closure that is called when the news stories have been retrieved. This closure takes a `Result` object with an array of `NewsStory` objects on success and an `Error` object on failure.
  public func news(
    for type: NewsViewController.`Type`,
    completion: @escaping (Result<[NewsStory], Error>) -> ()
  ) {
    switch type {
    case .topStories:
      makeAPIRequest(
        url: url(for: .topStories, queryParams: ["category": "general"]),
        expecting: [NewsStory].self,
        completion: completion
      )
    case let .company(symbol):
      let today = Date()
      let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7))
      makeAPIRequest(
        url: url(
          for: .companyNews,
          queryParams: [
            "symbol": symbol,
            "from": DateFormatter.newsDateFormatter.string(from: oneMonthBack),
            "to": DateFormatter.newsDateFormatter.string(from: today),
          ]
        ),
        expecting: [NewsStory].self,
        completion: completion
      )
    }
  }

  /// This method is implemented using the `makeAPIRequest` method, which is a private method that makes a request to an API and returns a response.
  /// This method calculates the start and end dates based on the number of days parameter and the current date.
  /// It then calls the `makeAPIRequest` method with the URL for the market data endpoint, the expected response type (`MarketDataResponse.self`), and the completion handler.
  ///
  /// - Parameters:
  ///   - symbol: The symbol of the financial instrument to retrieve market data for.
  ///   - numberOfDays: The number of days of market data to retrieve. This is an optional parameter with a default value of 7 days.
  ///   - completion: A closure that is called when the market data has been retrieved. This closure takes a `Result` object with a `MarketDataResponse` object on success and an `Error` object on failure.
  public func marketData(
    for symbol: String,
    numberOfDays: TimeInterval = 7,
    completion: @escaping (Result<MarketDataResponse, Error>) -> ()
  ) {
    let today = Date()
    let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
    makeAPIRequest(
      url: url(
        for: .marketData,
        queryParams: [
          "symbol": symbol,
          "resolution": "1",
          "from": "\(Int(prior.timeIntervalSince1970))",
          "to": "\(Int(today.timeIntervalSince1970))",
        ]
      ),
      expecting: MarketDataResponse.self,
      completion: completion
    )
  }

  /// This method is a public method that returns financial metrics for the given symbol
  ///
  /// - Parameters:
  ///   - symbol: The stock symbol for which the user wants to retrieve financial metrics.
  ///   - completion: A completion handler that returns a `Result` object containing either a `FinancialMetricsResponse` object or an `Error` object.
  public func financialMetrics(
    for symbol: String,
    completion: @escaping (Result<FinancialMetricsResponse, Error>) -> ()
  ) {
    let url = url(for: .financials, queryParams: ["symbol": symbol, "metric": "all"])
    makeAPIRequest(url: url, expecting: FinancialMetricsResponse.self, completion: completion)
  }

  // MARK: - Internal

  /// This method is a static method of the `APICaller` class that returns a singleton instance of the `APICaller`.
  /// This method is used to access the same instance of `APICaller` from anywhere within the application.
  static func shared() -> APICaller {
    return sharedInstance
  }

  // MARK: - Private

  /// The Constants property is a private enum that provides static constants for API keys, base URLs, and time intervals used to make API requests.
  private enum Constants {
    static let apiKey = "ch3atopr01qrc1e6mtogch3atopr01qrc1e6mtp0"
    static let sandboxApiKey = "ch3atopr01qrc1e6mtq0"
    static let baseUrl = "https://finnhub.io/api/v1/"
    static let day: TimeInterval = 3600 * 24
  }

  /// This property is a private enum that provides static cases for different API endpoints used to make API requests.
  /// In this example, `search`, `topStories`, `companyNews`, `marketData`, and `financials` are five endpoints used in this application.
  private enum Endpoint: String {
    case search
    case topStories = "news"
    case companyNews = "company-news"
    case marketData = "stock/candle"
    case financials = "stock/metric"
  }

  /// This property is a private enum that provides static cases for different API errors that may occur when making API requests.
  /// In this example, the `invalidUrl` and `noDataReturned` cases are used to handle errors that may occur when the API request URL is invalid or when no data is returned from the API.
  private enum APIError: Error {
    case invalidUrl
    case noDataReturned
  }

  /// This property is a private static instance of the `APICaller` class that is used to create a singleton instance of APICaller.
  /// This property is used to ensure that only one instance of APICaller is created and used throughout the application.
  private static let sharedInstance = APICaller()

  /// This method is a private method that takes an input parameter `parameters` of type `[String: String]` and returns a `String`.
  /// This method converts the given dictionary of parameters into a valid query string to be appended to the end of a URL.
  ///
  /// - Parameter parameters: A dictionary of key-value pairs representing the query parameters to be added to the URL.
  /// - Returns: This method returns a `String` value containing the query string constructed from the given `parameters`.
  private func queryString(fromParameters parameters: [String: String]) -> String {
    var queryItems = [URLQueryItem]()

    for (name, value) in parameters {
      queryItems.append(URLQueryItem(name: name, value: value))
    }

    queryItems.append(URLQueryItem(name: "token", value: Constants.apiKey))

    return queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
  }

  /// This method is used to construct a URL for a given endpoint and query parameters. It returns an optional URL.
  ///
  /// - Parameters:
  ///   - endpoint: An enumeration value of Endpoint type. It is used to specify the endpoint for which the URL needs to be constructed.
  ///   - queryParams:  dictionary of type `[String: String]` that contains query parameters. It is optional and its default value is an empty dictionary.
  /// - Returns: An optional `URL` object constructed by combining the baseUrl, endpoint, and queryParams. If the resulting URL is invalid, then it returns nil.
  private func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
    guard let url = URL(
      string: Constants.baseUrl + endpoint
        .rawValue + "?" + queryString(fromParameters: queryParams)
    ) else { return nil }
    return url
  }

  /// This method is used to make an API request for a given URL and decode the response into a specified type `T`.
  /// It accepts a completion handler that is called after the request is complete, either with a result of type `T` or an error.
  ///
  /// - Parameters:
  ///   - url: An optional `URL` object that specifies the URL for which the request needs to be made. If the URL is nil, then it returns an error.
  ///   - expecting: A generic parameter that specifies the type `T` into which the response should be decoded.
  ///   - completion: A closure that is called after the request is complete. It takes a `Result<T, Error>` parameter that contains either a result of type `T` or an error.
  private func makeAPIRequest<T: Codable>(
    url: URL?,
    expecting: T.Type,
    completion: @escaping (Result<T, Error>) -> ()
  ) {
    guard let url = url else {
      completion(.failure(APIError.invalidUrl))
      return
    }

    let task = URLSession.shared.dataTask(with: url) { data, _, error in
      guard let data = data, error == nil else {
        if let error = error {
          completion(.failure(error))
        } else {
          completion(.failure(APIError.noDataReturned))
        }
        return
      }

      completion(self.decodeResponse(from: data, expecting: expecting))
    }

    task.resume()
  }

  /// This method is used to decode the response data obtained from an API request into a specified type `T`.
  ///
  /// - Parameters:
  ///   - data: A `Data` object that contains the response data obtained from an API request.
  ///   - expecting: A generic parameter that specifies the type `T` into which the response data should be decoded.
  /// - Returns: A `Result<T, Error>` type that either contains the decoded result of type `T` or an error.
  private func decodeResponse<T: Codable>(from data: Data, expecting: T.Type) -> Result<T, Error> {
    do {
      let result = try JSONDecoder().decode(expecting, from: data)
      return .success(result)
    } catch {
      return .failure(error)
    }
  }
}
