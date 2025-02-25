//
//  ImgurVC.swift
//  CollectionTabView
//
//  Created by Mohammad Noor on 21/1/25.
//

import UIKit

class ImgurPicVC: UIViewController {
    
    weak var pickerDelegate: MemeMakerPickerControllerDelegate?
    
    var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    let baseURL = "https://api.bing.microsoft.com/v7.0/images/search"
    let subscriptionId = "1b5169696796482d9ee70c856cfea84e"
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    let mainCollectionViewCellItemSpacing: CGFloat = UIDevice.isIPad ? 2 : 3
    
    var gifInfo: [BingImageInfo] = []
    var currentPage = 0
    var isLoading = false
    var defSearchTag = "Interesting"
    var curSearchTag = "Interesting"
    let itemsPerPage = 30
    let cacheFolderName = "Web"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainCollectionView()
        loadGIFs()
        setUpSearchbar()
        overrideUserInterfaceStyle = .dark
        mainCollectionView.prefetchDataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavController()
        
    }
    
    func setUpSearchbar() {
        searchbar.delegate = self
    }
    
    func setUpNavController() {
        navigationController?.isNavigationBarHidden = false
    }
    
    func setUpMainCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = mainCollectionViewCellItemSpacing
        layout.minimumLineSpacing = mainCollectionViewCellItemSpacing
        mainCollectionView.collectionViewLayout = layout
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
       // mainCollectionView.register(UINib(nibName: ImgurPicCVCell.idetifier, bundle: nil), forCellWithReuseIdentifier: ImgurPicCVCell.idetifier)
        
    }
    
    func loadGIFs() {
        guard !isLoading else { return }
        isLoading = true
        let activeTag = curSearchTag
        BingImageSearchAPIManager.shared.fetchGIFs(query: defSearchTag, page: 0, baseUrl: baseURL, subscriptionKey: subscriptionId) { [weak self] gifInfo, error in
            guard activeTag == self?.curSearchTag
            else {
                return
            }
            
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let gifInfo = gifInfo else { return }
                self?.gifInfo.append(contentsOf: gifInfo)
                self?.mainCollectionView.reloadData()
                self?.currentPage += 1
            }
        }
    }
}

extension ImgurPicVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImgurPicCVCell.idetifier, for: indexPath) as! ImgurPicCVCell
        cell.internetConnectionIsAvailable(isAvailable: true)
        
        if(indexPath.item >= gifInfo.count) {
            cell.internetConnectionIsAvailable(isAvailable: false)
            return cell
        }
        
        let gifURL = MemeMakerPickerFileManager.shared.getFilePath(
            folderName: cacheFolderName,
            fileURL: gifInfo[indexPath.item].url
        )
        cell.tenorLoader.startAnimating()
        if FileManager.default.fileExists(atPath: gifURL.path) {
            cell.loadTenorGIF(fileURL: gifURL)
            return cell
        }
        
        let activeSearch = curSearchTag
        MemeMakerPickerFileManager.shared.downloadAsset(
            url: gifInfo[indexPath.item].url,
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
        if (collectionView == mainCollectionView) {
            let fileURL = MemeMakerPickerFileManager.shared.getFilePath(folderName: cacheFolderName, fileURL: gifInfo[indexPath.item].url)
            if(MemeMakerPickerFileManager.shared.isFileExists(fileUrl: fileURL)) {
                print("Tenor item \(indexPath.item) exists")
                pickerDelegate?.memeMakerMediaPickerController(didFinishPickingWithGif: fileURL)
            } else {
                print("Tenor item \(indexPath.item) does not exist")
            }
            dismiss(animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(collectionView.bounds.width, screenWidth)
        let numberOfCellsInRow: CGFloat = UIDevice.isIPad ? 4 : 3
        let width = (collectionView.bounds.width - mainCollectionViewCellItemSpacing * (numberOfCellsInRow-1)) / numberOfCellsInRow
        return CGSize(width: width, height: width)
    }
}

extension ImgurPicVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let needsFetch = indexPaths.contains { $0.row >= gifInfo.count - 5 }
        if needsFetch && !isLoading {
            loadMoreData()
        }
    }
    
    private func loadMoreData() {
        guard !isLoading else { return }
        isLoading = true
        currentPage += 1
        //searchInApiManager(curSearchTag, )
        BingImageSearchAPIManager.shared.fetchGIFs(query: curSearchTag, page: currentPage, baseUrl: baseURL, subscriptionKey: subscriptionId) { [weak self] newGIFs, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard let newGIFs = newGIFs else {
                    self.isLoading = false
                    return
                }
                
                
                self.gifInfo.append(contentsOf: newGIFs)
                
                DispatchQueue.main.async {
                    self.mainCollectionView.reloadData()
                }
                self.isLoading = false
            }
        }
    }
}

extension ImgurPicVC: UISearchBarDelegate {
    
    //when user changes the text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            currentPage = 0
            gifInfo.removeAll()
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
        gifInfo.removeAll()
        curSearchTag = searchBarText
        searchDefTagInApiManager(searchBarText, page: currentPage)
        
    }
    
    func searchInApiManager(_ searchText: String, page: Int ) {
        BingImageSearchAPIManager.shared.fetchGIFs(query: curSearchTag, page: page, baseUrl: baseURL, subscriptionKey: subscriptionId) { [weak self] newGIFs, error in
            DispatchQueue.main.async {
                guard
                    let self = self,
                    searchText == self.searchbar.text
                else {
                    return
                }
                
                guard let newGIFs = newGIFs else {
                    self.isLoading = false
                    return
                }
                
                
                self.gifInfo.append(contentsOf: newGIFs)
                self.mainCollectionView.reloadData()
                self.isLoading = false
            }
        }
    }
    
    func searchDefTagInApiManager(_ searchText: String, page: Int ) {
        BingImageSearchAPIManager.shared.fetchGIFs(query: curSearchTag, page: page, baseUrl: baseURL, subscriptionKey: subscriptionId) { [weak self] newGIFs, error in
            DispatchQueue.main.async {
                guard
                    let self = self else { return }
                
                guard let newGIFs = newGIFs else {
                    self.isLoading = false
                    return
                }
                
                self.gifInfo.append(contentsOf: newGIFs)
                self.mainCollectionView.reloadData()
                self.isLoading = false
            }
        }
    }
}
