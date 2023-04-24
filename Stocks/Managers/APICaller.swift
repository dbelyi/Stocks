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

  // MARK: Internal

  static let shared = APICaller()

  // MARK: Private

  private enum Constants {
    static let apiKey = ""
    static let sandboxApiKey = ""
    static let baseUrl = ""
  }

  private enum Endpoint: String {
    case search
  }

  private enum APIError: Error {
    case invalidUrl
    case noDataReturned
  }

  private func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
    return nil
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
