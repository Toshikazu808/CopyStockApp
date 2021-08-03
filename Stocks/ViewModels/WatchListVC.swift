//
//  ViewController.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/3/21.
//

import UIKit
import FloatingPanel

class WatchListVC: UIViewController {
   private var searchTimer: Timer?
   private var panel: FloatingPanelController?
   
   // MARK: - Lifecycle
   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .systemBackground
      setupTitleView()
      setupSearchController()
      setupFloatingPanel()
      // Child ViewController Example:
//      setupChild()
   }
   
   // MARK: - Private
   private func setupTitleView() {
      let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 100))
      let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width - 20, height: titleView.height))
      label.text = "Stocks"
      label.font = .systemFont(ofSize: 40, weight: .medium)
      titleView.addSubview(label)
      navigationItem.titleView = titleView
   }
   
   private func setupSearchController() {
      let resultVC = SearchResultsVC()
      resultVC.delegate = self
      let searchVC = UISearchController(searchResultsController: resultVC)
      searchVC.searchResultsUpdater = self
      navigationItem.searchController = searchVC
   }
   
   private func setupFloatingPanel() {
      let vc = NewsVC(type: .topStories)
      let panel = FloatingPanelController()
      panel.surfaceView.backgroundColor = .secondarySystemBackground
      panel.set(contentViewController: vc)
      panel.addPanel(toParent: self)
      panel.delegate = self
      panel.track(scrollView: vc.tableView)
   }
   
//   private func setupChild() {
//      let vc = PannelVC()
//      addChild(vc)
//      view.addSubview(vc.view)
//      vc.view.frame = CGRect(x: 0, y: view.height / 2, width: view.width, height: view.height)
//      vc.didMove(toParent: self)
//   }
}

extension WatchListVC: UISearchResultsUpdating {
   // Commonly used for Search APIs
   func updateSearchResults(for searchController: UISearchController) {
      guard let query = searchController.searchBar.text,
            let resultsVC = searchController.searchResultsController as? SearchResultsVC,
            !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
      
      searchTimer?.invalidate() // Resets the timer
      // Optimize to reduce number of searches when the user stops typing
      searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
         APICaller.shared.search(query: query) { result in
            switch result {
            case .success(let response):
               DispatchQueue.main.async {
                  resultsVC.update(with: response.result)
               }
               
            case .failure(let error):
               DispatchQueue.main.async {
                  resultsVC.update(with: [])
               }
               print(error)
            }
         }
      })
   }
}

extension WatchListVC: SearchResultsVCDelegate {
   func searchResultsVCDidSelect(searchResult: SearchResult) {
      navigationItem.searchController?.searchBar.resignFirstResponder()
      
      // Present stock details for given selection
      print("Did select: \(searchResult.displaySymbol)")
      let vc = StockDetailsVC()
      let navVC = UINavigationController(rootViewController: vc)
      vc.title = searchResult.description
      present(navVC, animated: true)
   }
}

extension WatchListVC: FloatingPanelControllerDelegate {
   func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
      navigationItem.titleView?.isHidden = fpc.state == .full
      
   }
}
