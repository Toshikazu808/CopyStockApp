//
//  StockDetailsVC.swift
//  Stocks
//
//  Created by Ryan Kanno on 8/3/21.
//

import UIKit
import SafariServices

class StockDetailsVC: UIViewController {
   // MARK: - Properties
   private let symbol: String
   private let companyName: String
   private var candleStickData: [CandleStick] = []
   
   private let tableView: UITableView = {
      let table = UITableView()
      table.register(
         NewsHeaderView.self,
         forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
      table.register(
         NewsStoryTableViewCell.self,
         forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
      return table
   }()
   
   private var stories: [NewsStory] = []
   private var metrics: Metrics?
   var dataFetchers = DataFetchers()
//   private let type: Constants.NewsType
   
   // MARK: - Init
   init(symbol: String, companyName: String, candleStickData: [CandleStick] = []) {
      self.symbol = symbol
      self.companyName = companyName
      self.candleStickData = candleStickData
      super.init(nibName: nil, bundle: nil)
   }
   
   required init?(coder: NSCoder) {
      fatalError()
   }
   
   // MARK: - Lifecycle
   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .systemBackground
      dataFetchers.delegateNews = self
      title = companyName
      setupCloseButton()
      setupTable()
      fetchFinancialData()
      fetchNews()
//      dataFetchers.fetchNews(type: type)
   }
   
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      tableView.frame = view.bounds
   }
   
   // MARK: - Private
   private func setupCloseButton() {
      navigationItem.rightBarButtonItem = UIBarButtonItem(
         barButtonSystemItem: .close,
         target: self,
         action: #selector(didTapClose))
   }
   
   @objc private func didTapClose() {
      dismiss(animated: true, completion: nil)
   }
   
   private func setupTable() {
      view.addSubview(tableView)
      tableView.delegate = self
      tableView.dataSource = self
      tableView.tableHeaderView = UIView(
         frame: CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: (view.width * 0.7) + 100))
   }
   
   private func fetchFinancialData() {
      // Fetch candle sticks if needed
      // If we come from search we don't have the candle stick data
      // If we come from the watchlist we do
      let group = DispatchGroup()
      if candleStickData.isEmpty {
         group.enter()
         APICaller.shared.marketData(for: symbol) { [weak self] result in
            defer {
               group.leave()
            }
            switch result {
            case .success(let response):
               print(response)
               self?.candleStickData = response.candleSticks
            case .failure(let error):
               print(error)
            }
         }
      }
      
      group.enter()
      APICaller.shared.financialMetrics(
         for: symbol) { [weak self] result in
         defer {
            group.leave()
         }
         switch result {
         case .success(let response):
            let metrics = response.metric
            self?.metrics = metrics
         case .failure(let error):
            print(error)
         }
      }
      
      group.notify(queue: .main) { [weak self] in
         self?.renderChart()
      }
   }
   
   private func renderChart() {
      // Chart VM | FinancialMetricViewModels
      let headerView = StockDetailHeaderView(
         frame: CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: (view.width * 0.7) + 100))
      
      var viewModels = [MetricCollectionViewCell.ViewModel]()
      if let metrics = metrics {
         viewModels.append(.init(name: "52W High", value: "\(metrics.AnnualHigh)"))
         viewModels.append(.init(name: "52W Low", value: "\(metrics.AnnualLow)"))
         viewModels.append(.init(name: "52W Return", value: "\(metrics.AnnualPriceReturnDaily)"))
         viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
         viewModels.append(.init(name: "10D Volume", value: "\(metrics.TenDayAverageTradingVolume)"))
      }
      
      let change = Calculators.shared.getChangePercentage(
         symbol: symbol,
         data: candleStickData)
      headerView.configure(
         chartViewModel: .init(
            data: candleStickData.reversed().map { $0.close },
            showLegend: true,
            showAxis: true,
            fillColor: change < 0 ? .systemRed : .systemGreen),
         metricViewModels: viewModels)
      
      tableView.tableHeaderView = headerView
   }
   
   private func fetchNews() {
      APICaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
         switch result {
         case .success(let stories):
            DispatchQueue.main.async {
               self?.stories = stories
               self?.tableView.reloadData()
            }            
         case .failure(let error):
            print(error)
         }
      }
   }
}

extension StockDetailsVC: DataFetchersDelegateNews {
   func updateUI(from stories: [NewsStory]) {
      self.stories = stories
      tableView.reloadData()
   }
}

extension StockDetailsVC: UITableViewDelegate, UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return stories.count
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
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return NewsStoryTableViewCell.preferredHeight
   }
   
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
         return nil
      }
      header.delegate = self
      header.configure(
         with: .init(
            title: symbol.uppercased(),
            shouldShowAddButton: !PersistenceManager.shared.watchlistContains(symbol: symbol)))
      return header
   }
   
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return NewsHeaderView.preferredHeight
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      guard let url = URL(string: stories[indexPath.row].url) else { return }
      let vc = SFSafariViewController(url: url)
      present(vc, animated: true)
   }
}

extension StockDetailsVC: NewsHeaderViewDelegate {
   func newsHeaderViewDidTappAddButton(_ headerView: NewsHeaderView) {
      headerView.button.isHidden = true
      PersistenceManager.shared.addToWatchList(
         symbol: symbol,
         companyName: companyName)
      let alert = UIAlertController(
         title: "Added to Watchlist",
         message: "\(companyName) has been added to your watchlist",
         preferredStyle: .alert)
      alert.addAction(
         UIAlertAction(
            title: "Dismiss",
            style: .cancel,
            handler: nil))
      present(alert, animated: true)
   }
}
