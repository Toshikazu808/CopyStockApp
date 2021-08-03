//
//  TopStoriesNewsVC.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/3/21.
//

import UIKit

class NewsVC: UIViewController {
   let tableView: UITableView = { // this is called an anonymous closure
      let table = UITableView()
      table.backgroundColor = .clear
      
      return table
   }()
   
   private let type: Type
   
   enum `Type` {
      case topStories
      case company(symbol: String)
      var title: String {
         switch self {
         case .topStories:
            return "Top Stories"
         case .company(let symbol):
            return symbol.uppercased()
         }
      }
   }
   
   // MARK: - Init
   init(type: Type) {
      self.type = type
      super.init(nibName: nil, bundle: nil)
   }
   
   required init?(coder: NSCoder) {
      fatalError()
   }
   
   // MARK: - Lifecycle
   override func viewDidLoad() {
      super.viewDidLoad()
      setupTable()
      fetchNews()
   }
   
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      tableView.frame = view.bounds
   }
   
   // MARK: - Private
   private func setupTable() {
      view.addSubview(tableView)
      tableView.delegate = self
      tableView.dataSource = self
   }
   
   private func fetchNews() {
      
   }
   
   private func open(url: URL) {
      
   }
   
}

extension NewsVC: UITableViewDelegate, UITableViewDataSource {
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return 70
   }
   
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      return nil
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return 0
   }
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 140
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return UITableViewCell()
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
   }
}
