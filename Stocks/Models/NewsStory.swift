//
//  NewsStory.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/4/21.
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
