//
//  Extensions.swift
//  Stocks
//
//  Created by Danila Belyi on 24.04.2023.
//

import Foundation
import UIKit

// MARK: - Framing

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
