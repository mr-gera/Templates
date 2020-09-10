//
//  SomeTableViewController.swift
//  Clewo
//
//  Created by Alex Gerasimov on 07.05.2020.
//  Copyright © 2020 zfort. All rights reserved.
//

import UIKit

struct DataItem: Codable {
    let userName: String?
}

class Provider {
    
    // MARK: - Private Properties
    private var items = [DataItem]()
    
    init() {
        prepareData()
    }
    
    // MARK: - Private Methods
    private func prepareData() {
        for i in 0...100 {
            items.append(DataItem(userName: "User \(i)"))
        }
    }
    
    // MARK: - Public Methods
    func getItems(page: Int, count: Int, closure: @escaping (_:  [DataItem]) -> Void) {
        if page * count + count > items.count {
            closure([])
        }
        
        var res = [DataItem]()
        
        for i in page * count ..< page * count + count {
            res += [items[i]]
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            closure(res)
        }
    }
}

class SomeTableViewController: UIViewController  {
    
    // MARK: - Private Properties
    private var items = [DataItem]()
    private var filtered = [DataItem]()
    private var currentPage = 0
    private var refreshControl = UIRefreshControl()
    private var dataLoading = false
    private let provider = Provider()
    private let itemsPerPage = 10
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Controller
    override func viewDidLoad() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        super.viewDidLoad()
        
        setupTableView()
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private Methods
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refresh() {
        currentPage = 0
        updateUI()
        loadData()
    }
    
    private func loadData(page: Int = 0, showHud: Bool = true) {
        if dataLoading {return}
        
//        if page * itemsPerPage + itemsPerPage <= items.count {
//            return
//        }
        
        if page == 0 {
            items.removeAll()
        }
        
        if showHud {
            ProgressHUD.showHud()
        }
        
        dataLoading = true
        provider.getItems(page: page, count: itemsPerPage) { [weak self] items in
        
            if showHud {
                ProgressHUD.hideHud()
            }
            
            guard let self = self else {return}
            
            if items.count > 0 {
                self.currentPage = page
            }
            
            self.items += items
            self.applyFilter()
            self.updateUI()
            
            self.dataLoading = false
        }
    }
    
    private func applyFilter() {
        filtered = items
    }
    
    private func updateUI() {
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
}

// MARK: - Extension Delegate
extension SomeTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filtered.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        cell.textLabel?.text = self.filtered[indexPath.row].userName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if dataLoading {return}
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            loadData(page: currentPage + 1, showHud: true)
        }
    }
}
