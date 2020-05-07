//
//  SomeCollectionViewController.swift
//  Clewo
//
//  Created by Alex Gerasimov on 07.05.2020.
//  Copyright © 2020 zfort. All rights reserved.
//

import UIKit

class SomeCollectionViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Private Properties

    fileprivate var refreshControl = UIRefreshControl()
    fileprivate let cellsPerRow = 2.0
    fileprivate var minimumInteritemSpacing = 8
    fileprivate var cellHeight = 230
    fileprivate let minimumLineSpacing = 8
    fileprivate var currentPage = 0
    fileprivate var items = ["Item1", "Item2"]
    fileprivate var loading = false
    
    // MARK: - Public Properties
    fileprivate var filters: [String:Any]?
    var delegate: ItemListViewControllerDelegate? = nil {
        didSet {
            loadData(filters: nil, showHud: true)
        }
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
       
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: String(describing: UICollectionViewCell.self))

        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
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
    
    func setupLayout() {
        
        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.minimumInteritemSpacing = CGFloat(minimumInteritemSpacing)
        flowLayout.minimumLineSpacing = CGFloat(minimumLineSpacing)
        flowLayout.sectionInset = UIEdgeInsets(top: CGFloat(minimumInteritemSpacing), left: CGFloat(minimumInteritemSpacing), bottom: CGFloat(minimumInteritemSpacing), right: CGFloat(minimumInteritemSpacing)) // not required
    }
    
    @objc func loadData(filters: [String:Any]?, page: Int = 0, showHud: Bool) {
        if loading {return}
        loading = true
        
        if page == 0 {
            currentPage = 0
            items.removeAll()
        }
        
        delegate?.loadData(filters: filters, pageNumber: page, countOnPage: 100, showHud: showHud) { [weak self]
            response in
            
            guard let self = self else {
                return
            }
            
            self.collectionView.reloadSections([1])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.loading = false
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    
    @objc private func refresh() {
        currentPage = 0
        loadData(filters: filters, page: 0, showHud: true)
    }

    
    func applyFilters() {
        
        self.currentPage = 0
        self.loadData(filters: self.filters, page: 0, showHud: true)
    }
    
    @objc func updateCell(cell: UICollectionViewCell, at indexPath: IndexPath) {
        
        if indexPath.row >= items.count {return}
        let item = items[indexPath.row]
        let label = UILabel(frame: cell.bounds)
        label.text = item
        label.textAlignment = .center
        label.backgroundColor = .gray
        cell.addSubview(label)
    }
}

extension SomeCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UICollectionViewCell.self), for: indexPath)
        updateCell(cell: cell, at: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
       
        return CGFloat(minimumLineSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: CGFloat(minimumLineSpacing), left: CGFloat(minimumLineSpacing), bottom: CGFloat(minimumLineSpacing), right: CGFloat(minimumLineSpacing)) // not required
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = CGFloat(collectionView.frame.width) / CGFloat(cellsPerRow)
       
        width -= (CGFloat(minimumInteritemSpacing))
        width -= (CGFloat(cellsPerRow - 1) * CGFloat(minimumInteritemSpacing / 2))
        
        return CGSize(width: width, height: CGFloat(cellHeight))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if loading {return}
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            loadData(filters: filters, page: currentPage + 1, showHud: true)
        }
    }
    
}

extension SomeCollectionViewController: StoryboardLoadable {
    static var storyboardName: String {
        return "Utility"
    }
}
