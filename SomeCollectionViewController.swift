//
//  SomeCollectionViewController.swift
//  Clewo
//
//  Created by Alex Gerasimov on 07.05.2020.
//  Copyright © 2020 zfort. All rights reserved.
//

import UIKit

fileprivate struct DataItem: Codable {
    let userName: String?
}

fileprivate class Provider {
    
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

@IBDesignable
class SomeCollectionViewController: UIViewController {
    
    @IBInspectable var cellsPerRow: Int = 2
    @IBInspectable var minimumInteritemSpacing: Int = 8
    @IBInspectable var cellHeight: Int = 40
    @IBInspectable var minimumLineSpacing: Int = 8
    @IBInspectable var itemsPerPage: Int = 10
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Private Properties

    private var refreshControl = UIRefreshControl()

    private var currentPage = 0
    private var items = [DataItem]()
    private var filtered = [DataItem]()
    private var dataLoading = false
    private let provider = Provider()
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.reloadData()
        setupCollectionView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
    }
    
    // MARK: - Private Type Methods
    
    func setupCollectionView() {
        
        collectionView.register(SomeCollectionViewCell.nib(), forCellWithReuseIdentifier: String(describing: SomeCollectionViewCell.self))
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.dataSource = self

        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.minimumInteritemSpacing = CGFloat(minimumInteritemSpacing)
        flowLayout.minimumLineSpacing = CGFloat(minimumLineSpacing)
        flowLayout.sectionInset = UIEdgeInsets(top: CGFloat(minimumInteritemSpacing), left: CGFloat(minimumInteritemSpacing), bottom: CGFloat(minimumInteritemSpacing), right: CGFloat(minimumInteritemSpacing)) // not required
    }
    
    @objc private func refresh() {
        currentPage = 0
        updateUI()
        loadData()
    }
    
    private func loadData(page: Int = 0, showHud: Bool = true) {
        if dataLoading {return}
        
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
        collectionView.reloadData()
    }
    
    @objc func updateCell(cell: SomeCollectionViewCell, at indexPath: IndexPath) {
        
        if indexPath.row >= filtered.count {return}
        let item = filtered[indexPath.row]
        
        cell.titleLabel.text = item.userName
    }
}

extension SomeCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SomeCollectionViewCell.self), for: indexPath) as! SomeCollectionViewCell
        
        updateCell(cell: cell, at: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
       
        return CGFloat(minimumLineSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: CGFloat(minimumLineSpacing), left: CGFloat(minimumLineSpacing), bottom: CGFloat(minimumLineSpacing), right: CGFloat(minimumLineSpacing)) // not required
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = CGFloat(collectionView.frame.width) / CGFloat(cellsPerRow)
       
        width -= (CGFloat(minimumInteritemSpacing * 2))
        width -= (CGFloat(cellsPerRow - 1) * CGFloat(minimumInteritemSpacing / 2))
        width += CGFloat(minimumInteritemSpacing / 2)
        
        return CGSize(width: width, height: CGFloat(cellHeight))
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

extension SomeCollectionViewController: StoryboardLoadable {
    static var storyboardName: String {
        return "Utility"
    }
}
