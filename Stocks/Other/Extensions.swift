//
//  Extensions.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import Foundation
import UIKit

// MARK: - DateFormatter

extension DateFormatter {
  static let newsDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
  }()
}

// MARK: - Add Subview

extension UIView {
  func addSubviews(_ views: UIView...) {
    views.forEach {
      addSubview($0)
    }
  }
}

// MARK: - Framing

/// An extension of the `UIView` class that adds computed properties for the size and position of a view relative to its frame
extension UIView {
  var width: CGFloat {
    frame.size.width
  }

  var height: CGFloat {
    frame.size.height
  }

  var left: CGFloat {
    frame.origin.x
  }

  var right: CGFloat {
    left + width
  }

  var top: CGFloat {
    frame.origin.y
  }

  var bottom: CGFloat {
    top + height
  }
}
