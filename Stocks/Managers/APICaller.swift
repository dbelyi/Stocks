//
//  APICaller.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import Foundation

final class APICaller {
  // MARK: Lifecycle

  private init() {}

  // MARK: Public

  public func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> ()) {
    guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    else { return }
    request(
      url: url(for: .search, queryParams: ["q": safeQuery]),
      expecting: SearchResponse.self,
      completion: completion
    )
  }

  // MARK: Internal

  static let shared = APICaller()

  // MARK: Private

  private enum Constants {
    static let apiKey = "ch3atopr01qrc1e6mtogch3atopr01qrc1e6mtp0"
    static let sandboxApiKey = "ch3atopr01qrc1e6mtq0"
    static let baseUrl = "https://finnhub.io/api/v1/"
  }

  private enum Endpoint: String {
    case search
  }

  private enum APIError: Error {
    case invalidUrl
    case noDataReturned
  }

  private func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
    var urlString = Constants.baseUrl + endpoint.rawValue
    var queryItems = [URLQueryItem]()

    /// Add any parameters
    for (name, value) in queryParams {
      queryItems.append(.init(name: name, value: value))
    }

    /// Add token
    queryItems.append(.init(name: "token", value: Constants.apiKey))

    /// Convert query items to suffix string
    urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")

    print("\n\(urlString)\n")

    return URL(string: urlString)
  }

  /**
   Sends a network request and receives a response in JSON format.

   - Parameters:
      - url: The URL to send the request to.
      - expecting: The type of the expected response.
      - completion: A closure to handle the result.

   If the URL is not specified, the `APIError.invalidUrl` error is passed to the
   completion closure. A `URLSession` task is created that sends a request to the
   specified URL. If there is data in the response and no errors, the data is decoded
   from JSON into the specified type and passed to the completion closure as a
   successful result. Otherwise, an error is passed to the completion closure.
   */
  private func request<T: Codable>(
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

      do {
        let result = try JSONDecoder().decode(expecting, from: data)
        completion(.success(result))
      } catch {
        completion(.failure(error))
      }
    }

    task.resume()
  }
}
