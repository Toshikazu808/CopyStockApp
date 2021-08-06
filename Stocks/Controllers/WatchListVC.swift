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
   static var maxChangeWidth: CGFloat = 0
   // Model objects
   private var watchlistMap: [String: [CandleStick]] = [:]
   
   // ViewModel objects
   private var viewModels: [WatchListTableViewCell.ViewModel] = []
   private let tableView: UITableView = {
      let table = UITableView()
      table.register(
         WatchListTableViewCell.self,
         forCellReuseIdentifier: WatchListTableViewCell.identifier)
      return table
   }()
   private var observer: NSObjectProtocol?
   
   // MARK: - Lifecycle
   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .systemBackground
      setupTitleView()
      setupTableView()
      fetchWatchlistData()
      setupSearchController()
      setupFloatingPanel()
      setupObserver()
      // Child ViewController Example:
//      setupChild()
   }
   
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      tableView.frame = view.bounds
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
   
   private func setupTableView() {
      view.addSubview(tableView)
      tableView.delegate = self
      tableView.dataSource = self
   }
   
   private func fetchWatchlistData() {
      let symbols = PersistenceManager.shared.watchList
      let group = DispatchGroup()
      
      for symbol in symbols where watchlistMap[symbol] == nil {
         group.enter()
         APICaller.shared.marketData(for: symbol) { [weak self] result in
            defer {
               group.leave()
            }
            switch result {
            case .success(let data):
               let candleSticks = data.candleSticks
               self?.watchlistMap[symbol] = candleSticks
            case .failure(let error):
               print(error)
            }
         }
      }
      group.notify(queue: .main) { [weak self] in
         self?.createViewModels()
         self?.tableView.reloadData()
      }
   }
   
   private func createViewModels() {
      var viewModels = [WatchListTableViewCell.ViewModel]()
      
      for (symbol, candleSticks) in watchlistMap {
         let changePercentage = getChangePercentage(
            symbol: symbol,
            data: candleSticks)
         
         viewModels.append(
            .init(
               symbol: symbol,
               companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
               price: getLatestClosingPrice(from: candleSticks),
               changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
               changePercentage: .percentage(from: changePercentage),
               chartViewModel: .init(
                  data: candleSticks.reversed().map{ $0.close },
                  showLegend: false,
                  showAxis: false)))
      }
      self.viewModels = viewModels
   }
   
   private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
//      let priorDate = Date().addingTimeInterval(-(3600 * 24 * 2))
      let latestDate = data[0].date
      
      guard let latestClose = data.first?.close,
            let priorClose = data.first(where: {
               !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
            })?.close else {
         return 0
      }
      let difference = 1 - (priorClose / latestClose)
      return difference
   }
   
   private func getLatestClosingPrice(from data: [CandleStick]) -> String {
      guard let closingPrice = data.first?.close else { return "" }
      return String.formatted(number: closingPrice)
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
   
   private func setupObserver() {
      observer = NotificationCenter.default.addObserver(
         forName: .didAddToWatchList,
         object: nil,
         queue: .main,
         using: { [weak self] _ in
            self?.viewModels.removeAll()
            self?.fetchWatchlistData()
         })
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
      let vc = StockDetailsVC(
         symbol: searchResult.displaySymbol,
         companyName: searchResult.description)
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

extension WatchListVC: UITableViewDelegate, UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return viewModels.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(
               withIdentifier: WatchListTableViewCell.identifier,
               for: indexPath) as? WatchListTableViewCell else { fatalError() }
      cell.delegate = self
      cell.configure(with: viewModels[indexPath.row])
      return cell
   }
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return WatchListTableViewCell.preferredHeight
   }
   
   func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      return true
   }
   
   func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
      return .delete
   }
   
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
         tableView.beginUpdates()
         
         // Update persistence
         PersistenceManager.shared.removeFromWatchList(symbol: viewModels[indexPath.row].symbol)
         
         // Update viewModels
         viewModels.remove(at: indexPath.row)
         
         // Delete row
         tableView.deleteRows(at: [indexPath], with: .automatic)
         
         tableView.endUpdates()
      }
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      // Open details for selection
      let viewModel = viewModels[indexPath.row]
      let vc = StockDetailsVC(
         symbol: viewModel.symbol,
         companyName: viewModel.companyName,
         candleStickData: watchlistMap[viewModel.symbol] ?? [])
      let navVC = UINavigationController(rootViewController: vc)
      present(navVC, animated: true)
   }
}

extension WatchListVC: WatchListTableViewCellDelegate {
   func didUpdateMaxWidth() {
      // Optimize: only refresh rows prior to the currenet row that changes the max width
      tableView.reloadData()
   }
}
