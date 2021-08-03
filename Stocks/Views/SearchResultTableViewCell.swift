//
//  SearchResultTableViewCell.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/3/21.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
   static let identifier = "SearchResultTableViewCell"
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
   }
   
   required init?(coder: NSCoder) {
      fatalError()
   }

}
