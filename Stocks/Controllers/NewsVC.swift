//
//  TopStoriesNewsVC.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/3/21.
//

import UIKit
import SafariServices

/// Child controller for WatchListVC
/// Contained in FloatingPanelController()
class NewsVC: UIViewController {
   // MARK: - Properties
   let tableView: UITableView = {
      let table = UITableView()
      table.backgroundColor = .clear
      table.register(
         NewsStoryTableViewCell.self,
         forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
      table.register(
         NewsHeaderView.self,
         forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
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
   private var stories = [NewsStory]()
   var dataFetchers = DataFetchers()
   
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
      dataFetchers.delegateNews = self
      setupTable()
//      fetchNews()
      dataFetchers.fetchNews(type: type)
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
   
   private func open(url: URL) {
      let vc = SFSafariViewController(url: url)
      present(vc, animated: true)
   }
   
}

extension NewsVC: DataFetchersDelegateNews {
   func updateUI(from stories: [NewsStory]) {
      self.stories = stories
      tableView.reloadData()
   }
}

extension NewsVC: UITableViewDelegate, UITableViewDataSource {
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return NewsHeaderView.preferredHeight
   }
   
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      guard let header = tableView.dequeueReusableHeaderFooterView(
               withIdentifier: NewsHeaderView.identifier)
               as? NewsHeaderView else { return nil }
      header.configure(with: .init(
                        title: self.type.title,
                        shouldShowAddButton: false))
      return header
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return stories.count
   }
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return NewsStoryTableViewCell.preferredHeight
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(
               withIdentifier: NewsStoryTableViewCell.identifier,
               for: indexPath) as? NewsStoryTableViewCell else {
         fatalError()
      }
      cell.configure(with: .init(model: stories[indexPath.row]))
      return cell
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      let story = stories[indexPath.row]
      guard let url = URL(string: story.url) else {
         presentFailedToOpenAlert()
         return
      }
      open(url: url)
   }
   
   private func presentFailedToOpenAlert() {
      let alert = UIAlertController(
         title: "Unable to open",
         message: "We were unable to ope nthe article.",
         preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
      present(alert, animated: true)
   }
}
