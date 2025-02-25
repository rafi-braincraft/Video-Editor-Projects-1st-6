//
//  ClipsVC.swift
//  CollectionTabView
//
//  Created by Mohammad Noor on 19/1/25.
//

import UIKit

class ClipsVC: UIViewController {
    
    var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    @IBOutlet weak var clipsCollectionView: UICollectionView!
    
    @IBOutlet weak var clipsSearchBar: UISearchBar!
    
    var gifURLs: [String] = []
    var currentPage = 0
    var isLoading = false
    var selectedSearchTag = "funny"
    let itemsPerPage = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpClipsCollectionView()
        loadGIFs()
        overrideUserInterfaceStyle = .dark
    }
    
    func setUpClipsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        clipsCollectionView.collectionViewLayout = layout
        
        clipsCollectionView.delegate = self
        clipsCollectionView.dataSource = self
        clipsCollectionView.register(UINib(nibName: "ClipsCVCell", bundle: nil), forCellWithReuseIdentifier: "ClipsCVCell")
        
    }
    
    func loadGIFs() {
        guard !isLoading else { return }
        isLoading = true
        TenorAPIManager.shared.fetchGIFs(query: selectedSearchTag, page: currentPage) { [weak self] gifURLs in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let gifURLs = gifURLs else { return }
                self?.gifURLs.append(contentsOf: gifURLs)
                self?.clipsCollectionView.reloadData()
                self?.currentPage += 1
            }
        }
    }
}

extension ClipsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClipsCVCell", for: indexPath) as! ClipsCVCell
        cell.configure(gifURL: gifURLs[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(collectionView.bounds.width, screenWidth)
        let width: CGFloat = (collectionView.bounds.width - 8)/2
        let height: CGFloat = (width/193)*116
        
        return CGSize(width: width, height: height)
    }
}

extension ClipsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let offset = scrollView.contentOffset.y
        let height = scrollView.frame.size.height
        
        if !isLoading && offset > contentHeight - height - 100 {
            print("ScrollView did scroll, loading more data...")
            loadMoreData()
        }
    }
    
    private func loadMoreData() {
        guard !isLoading else { return }
        isLoading = true
        currentPage += 1
        TenorAPIManager.shared.fetchGIFs(query: selectedSearchTag, page: currentPage) { [weak self] gifURLs in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard let newGIFs = gifURLs else {
                    self.isLoading = false
                    return
                }
                
                self.gifURLs.append(contentsOf: newGIFs)
                self.clipsCollectionView.reloadData()
                self.isLoading = false
            }
        }
    }
}
