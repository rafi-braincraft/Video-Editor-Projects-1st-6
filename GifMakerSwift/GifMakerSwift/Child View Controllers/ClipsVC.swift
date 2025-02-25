//
//  ClipsVC.swift
//  CollectionTabView
//
//  Created by Mohammad Noor on 19/1/25.
//

import UIKit

class ClipsVC: UIViewController {
    
    weak var pickerDelegate: MemeMakerPickerControllerDelegate?
    
    var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    @IBOutlet weak var clipsCollectionView: UICollectionView!
    
    @IBOutlet weak var clipsSearchBar: UISearchBar!
    
    let mainCollectionViewCellItemSpacing: CGFloat = UIDevice.isIPad ? 14 : 8
    
    var gifURLs: [String] = []
    var currentPage = 0
    var isLoading = false
    var defSearchTag = "funny"
    var curSearchTag = "funny"
    let itemsPerPage = 30
    let cacheFolderName = "Clips"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpClipsCollectionView()
        loadGIFs()
        setUpClilpsSearchBar()
        overrideUserInterfaceStyle = .dark
        clipsCollectionView.prefetchDataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavController()
        
    }
    
    func setUpClilpsSearchBar() {
        clipsSearchBar.delegate = self
    }
    
    func setUpNavController() {
        navigationController?.isNavigationBarHidden = false
        //self.navigationItem.title = "Clips"
    }
    
    func setUpClipsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = mainCollectionViewCellItemSpacing
        layout.minimumLineSpacing = mainCollectionViewCellItemSpacing
        clipsCollectionView.collectionViewLayout = layout
        
        clipsCollectionView.delegate = self
        clipsCollectionView.dataSource = self
        clipsCollectionView.register(UINib(nibName: "ClipsCVCell", bundle: nil), forCellWithReuseIdentifier: "ClipsCVCell")
        
    }
    
    func loadGIFs() {
        guard !isLoading else { return }
        isLoading = true
        let activeTag = curSearchTag
        ClipsApiManager.shared.fetchGIFs(query: defSearchTag, page: currentPage) { [weak self] gifURLs, error in
            guard activeTag == self?.curSearchTag
            else {
                return
            }
            
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
        cell.internetConnectionIsAvailable(isAvailable: true)
        
        if(indexPath.item>=gifURLs.count) {
            cell.internetConnectionIsAvailable(isAvailable: false)
            return cell
        }
        
        let gifURL = MemeMakerPickerFileManager.shared.getFilePath(
            folderName: cacheFolderName,
            fileURL: gifURLs[indexPath.item]
        )
        cell.clipsCellLoader.startAnimating()
        if FileManager.default.fileExists(atPath: gifURL.path) {
            cell.loadGif(fileURL: gifURL)
            return cell
        }
        
        let activeSearch = curSearchTag
        MemeMakerPickerFileManager.shared.downloadAsset(
            url: gifURLs[indexPath.item],
            folderName: cacheFolderName
        ) {[weak self] cacheURL, error in
            DispatchQueue.main.async {[weak self] in
                guard
                    let cell = collectionView.cellForItem(at: indexPath) as? ClipsCVCell,
                    activeSearch == self?.curSearchTag
                else {
                    return
                }
                
                if
                    let cacheURL = cacheURL
                {
                    cell.loadGif(fileURL: cacheURL)
                } else {
                    cell.internetConnectionIsAvailable(isAvailable: false)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == clipsCollectionView) {
            let fileURL = MemeMakerPickerFileManager.shared.getFilePath(folderName: cacheFolderName, fileURL: gifURLs[indexPath.item])
            if(MemeMakerPickerFileManager.shared.isFileExists(fileUrl: fileURL)) {
                print("Tenor item \(indexPath.item) exists")
                pickerDelegate?.memeMakerMediaPickerController(didFinishPickingWithGif: fileURL)
            }
            dismiss(animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(collectionView.bounds.width, screenWidth)
        let width = (collectionView.bounds.width - mainCollectionViewCellItemSpacing)/2
        let height: CGFloat = UIDevice.isIPad ? (width * 116 / 193) : (width * 196 / 325)
        return CGSize(width: width, height: height)
    }
}

extension ClipsVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let needsFetch = indexPaths.contains { $0.row >= gifURLs.count - 5 }
        if needsFetch && !isLoading {
            loadMoreData()
        }
    }
    
    private func loadMoreData() {
        guard !isLoading else { return }
        isLoading = true
        currentPage += 1
        //searchInApiManager(curSearchTag, )
        ClipsApiManager.shared.fetchGIFs(query: curSearchTag, page: currentPage) { [weak self] gifURLs, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard let newGIFs = gifURLs else {
                    self.isLoading = false
                    return
                }
                
                
                self.gifURLs.append(contentsOf: newGIFs)
                
                DispatchQueue.main.async {
                    self.clipsCollectionView.reloadData()
                }
                self.isLoading = false
            }
        }
    }
}

extension ClipsVC: UISearchBarDelegate {
    
    //when user changes the text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            currentPage = 0
            gifURLs.removeAll()
            curSearchTag = defSearchTag
            searchDefTagInApiManager(defSearchTag, page: currentPage)
            print("default clips search")
        }
    }
    
    //when user tapped on the search button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchBarText = searchBar.text else {
            print("empty search bar")
            return
        }
        
        currentPage = 0
        gifURLs.removeAll()
        curSearchTag = searchBarText
        searchDefTagInApiManager(searchBarText, page: currentPage)
        
    }
    
    func searchInApiManager(_ searchText: String, page: Int ) {
        ClipsApiManager.shared.fetchGIFs(query: searchText, page: page) { [weak self] gifURLs, error in
            DispatchQueue.main.async {
                guard
                    let self = self,
                    searchText == self.clipsSearchBar.text
                else {
                    return
                }
                
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
    
    func searchDefTagInApiManager(_ searchText: String, page: Int ) {
        ClipsApiManager.shared.fetchGIFs(query: searchText, page: page) { [weak self] gifInfo, error in
            DispatchQueue.main.async {
                guard
                    let self = self else { return }
                
                guard let newGIFs = gifInfo else {
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
