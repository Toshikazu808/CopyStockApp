//
//  SearchResultsVC.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/3/21.
//

import UIKit

protocol SearchResultsVCDelegate: AnyObject {
   func searchResultsVCDidSelect(searchResult: SearchResult)
}

class SearchResultsVC: UIViewController {
   weak var delegate: SearchResultsVCDelegate?
   private var results: [SearchResult] = []
   private let tableView: UITableView = {
      let table = UITableView()
      table.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
      table.isHidden = true
      return table
   }()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .systemBackground
      setupTable()
   }
   
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      tableView.frame = view.bounds
   }
   
   private func setupTable() {
      view.addSubview(tableView)
      tableView.delegate = self
      tableView.dataSource = self
   }
   
   public func update(with results: [SearchResult]) {
      self.results = results
      tableView.isHidden = results.isEmpty
      tableView.reloadData()
   }
   
}

extension SearchResultsVC: UITableViewDelegate, UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return results.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
      let model = results[indexPath.row]
      cell.textLabel?.text = model.displaySymbol
      cell.detailTextLabel?.text = model.description
      return cell
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      let model = results[indexPath.row]
      delegate?.searchResultsVCDidSelect(searchResult: model)
   }
}
