//
//  Extensions.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import Foundation
import UIKit

// MARK: - Notification

extension Notification.Name {
  /// Notification for when symbols gets added to watchlist
  static let didAddToWatchList = Notification.Name("didAddToWatchList")
}

// MARK: - NumberFormatter

extension NumberFormatter {
  /// Formatter for percent style
  static let percentFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 2
    return formatter
  }()

  /// Formatter for decimal style
  static let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    return formatter
  }()
}

// MARK: - UIImageView

extension UIImageView {
  /// This method is designed to asynchronously set an image on a UIImageView from a URL
  ///
  /// - Parameter url: A URL object of the image
  func setImage(with url: URL?) {
    guard let url = url else {
      return
    }

    DispatchQueue.global(qos: .userInteractive).async {
      let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
        guard let data = data, error == nil else {
          return
        }
        DispatchQueue.main.async {
          self?.image = UIImage(data: data)
        }
      }
      task.resume()
    }
  }
}

// MARK: - String

extension String {
  /// This method returns a string representation of a `TimeInterval` value in a human-readable format using the `prettyDateFormatter` of the `DateFormatter` class.
  ///
  /// - Parameter timeInterval: A `TimeInterval` value representing the amount of time since January 1st, 1970.
  /// - Returns: A String representing the timeInterval in a human-readable format.
  static func string(from timeInterval: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: timeInterval)
    return DateFormatter.prettyDateFormatter.string(from: date)
  }

  /// This method returns a string representation of a Double value as a percentage using the `percentFormatter` of the `NumberFormatter` class.
  ///
  /// - Parameter double: A Double value representing a decimal number to be converted to a percentage.
  /// - Returns: A String representing the double value as a percentage.
  static func percentage(from double: Double) -> String {
    let formatter = NumberFormatter.percentFormatter
    return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
  }

  /// This method returns a string representation of a Double value using the `numberFormatter` of the `NumberFormatter` class.
  ///
  /// - Parameter number: A Double value representing a number to be formatted.
  /// - Returns: A String representing the number value in a formatted manner.
  static func formatted(number: Double) -> String {
    let formatter = NumberFormatter.numberFormatter
    return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
  }
}

// MARK: - DateFormatter

extension DateFormatter {
  /// This property is a static constant variable that is used to format dates in the format "YYYY-MM-dd" using the `DateFormatter` class.
  /// This property is useful when working with news articles or blog posts that have a specific date format.
  static let newsDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
  }()

  /// This property is a static constant variable that is used to format dates in a user-friendly format using the `DateFormatter` class.
  /// This property is useful when displaying dates to users in a more readable format.
  static let prettyDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
  }()
}

// MARK: - Add Subview

extension UIView {
  /// This method is a custom function that takes multiple UIView objects as a parameter and adds them as subviews to the current view.
  ///
  /// - Parameter views: A variadic parameter that accepts a list of UIView objects.
  func addSubviews(_ views: UIView...) {
    views.forEach {
      addSubview($0)
    }
  }
}

// MARK: - Framing

extension UIView {
  /// Returns the width of the view's frame.
  var width: CGFloat {
    frame.size.width
  }

  /// Returns the height of the view's frame.
  var height: CGFloat {
    frame.size.height
  }

  /// Returns the x-coordinate of the view's frame.
  var left: CGFloat {
    frame.origin.x
  }

  /// Returns the sum of the x-coordinate and width of the view's frame.
  var right: CGFloat {
    left + width
  }

  /// Returns the y-coordinate of the view's frame.
  var top: CGFloat {
    frame.origin.y
  }

  /// Returns the sum of the y-coordinate and height of the view's frame.
  var bottom: CGFloat {
    top + height
  }
}
