//
//  NewsStory.swift
//  Stocks
//
//  Created by Danila Belyi on 26.04.2023.
//

import Foundation

struct NewsStory: Codable {
  let category: String
  let datetime: TimeInterval
  let headline: String
  let image: String
  let related: String
  let source: String
  let summary: String
  let url: String
}
