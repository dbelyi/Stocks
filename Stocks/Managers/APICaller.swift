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

  /// Search for articles that match the given query string.
  /// - Parameters:
  ///   - query: The query string to search for.
  ///   - completion: A closure that will be called with the search results, or an error if the search failed.
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

  public func financialMetrics(
    for symbol: String,
    completion: @escaping (Result<FinancialMetricsResponse, Error>) -> ()
  ) {
    let url = url(for: .financials, queryParams: ["symbol": symbol, "metric": "all"])
    makeAPIRequest(url: url, expecting: FinancialMetricsResponse.self, completion: completion)
  }

  // MARK: - Internal

  static func shared() -> APICaller {
    return sharedInstance
  }

  // MARK: - Private

  private enum Constants {
    static let apiKey = "ch3atopr01qrc1e6mtogch3atopr01qrc1e6mtp0"
    static let sandboxApiKey = "ch3atopr01qrc1e6mtq0"
    static let baseUrl = "https://finnhub.io/api/v1/"
    static let day: TimeInterval = 3600 * 24
  }

  private enum Endpoint: String {
    case search
    case topStories = "news"
    case companyNews = "company-news"
    case marketData = "stock/candle"
    case financials = "stock/metric"
  }

  private enum APIError: Error {
    case invalidUrl
    case noDataReturned
  }

  private static let sharedInstance = APICaller()

  /// Build a query string for the given parameters.
  ///
  /// - Parameters:
  ///   - parameters: A dictionary of parameters to be included in the query string.
  /// - Returns: A string representing the URL query string constructed from the provided parameters.
  private func queryString(fromParameters parameters: [String: String]) -> String {
    var queryItems = [URLQueryItem]()

    for (name, value) in parameters {
      queryItems.append(URLQueryItem(name: name, value: value))
    }

    queryItems.append(URLQueryItem(name: "token", value: Constants.apiKey))

    return queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
  }

  /// Build a URL for the given endpoint and query parameters.
  ///
  /// - Parameters:
  ///   - endpoint: The endpoint to use.
  ///   - queryParams: The query parameters to include in the request.
  /// - Returns: A URL for the given endpoint and query parameters, or `nil` if the URL was invalid.
  private func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
    guard let url = URL(
      string: Constants.baseUrl + endpoint
        .rawValue + "?" + queryString(fromParameters: queryParams)
    ) else { return nil }
    return url
  }

  /// Make an API request and decode the response.
  ///
  /// - Parameters:
  ///   - url: The URL to request.
  ///   - expecting: The expected type of the response.
  ///   - completion: A closure that will be called with the decoded response, or an error if the request failed.
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

  /// Decode the response data into the expected type.
  ///
  /// - Parameters:
  ///   - data: The raw response data.
  ///   - expecting: The expected type of the response.
  /// - Returns: A `Result` with the decoded response, or an error if decoding failed.
  private func decodeResponse<T: Codable>(from data: Data, expecting: T.Type) -> Result<T, Error> {
    do {
      let result = try JSONDecoder().decode(expecting, from: data)
      return .success(result)
    } catch {
      return .failure(error)
    }
  }
}
