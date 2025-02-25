//
//  BaseWaterfallGifVC.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 9/2/25.
//

import UIKit

class GiphyVC: UIViewController {
    
    weak var pickerDelegate: MemeMakerPickerControllerDelegate?
    //set this from ther respective viewControllers
    private let debouncer = Debouncer(delay: 0.5)
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var suggestionCollectionView: UICollectionView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    var cacheFolderName: String = "Giphy"
    private let mainCollectionViewBaseURL: String = "https://api.giphy.com/v1/gifs/search"
    private let mainCollectionViewApiKey: String = "PlURhRCOonSbaNeW38oDfV3p0z31i912"
    private let suggestionBaseURL = "https://api.giphy.com/v1/gifs/search/tags"
    private let suggestionApiKey = "PlURhRCOonSbaNeW38oDfV3p0z31i912"
    
    var selectedSuggestionIndexPath: IndexPath?
    var waterfallInfoData: [GiphyInfo] = []
    var currentPage = 0
    var isLoading = false
    var defSearchTag = "Funny"
    var currentSearchTag = "Funny"
    var defSuggestionSearchTag = "Funny"
    
    var suggestionData: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainCollectionView()
        setUpSuggestionCollectionView()
        loadGIFURLs()
        setUpSearchBar()
        searchBar(searchBar, textDidChange: defSuggestionSearchTag)
        overrideUserInterfaceStyle = .dark
        mainCollectionView.prefetchDataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigationBar()
    }
    
    func setUpNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        //self.navigationItem.title = "Tenor"
    }
    
    func setUpMainCollectionView() {
        let waterFallLayout = WaterfallLayout(with: self)
        waterFallLayout.itemSpacing = 10
        mainCollectionView.collectionViewLayout = waterFallLayout
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(UINib(nibName: TenorCVCell.idetifier, bundle: nil), forCellWithReuseIdentifier: TenorCVCell.idetifier)
    }
    
    func setUpSuggestionCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        suggestionCollectionView.collectionViewLayout = layout
        suggestionCollectionView.delegate = self
        suggestionCollectionView.dataSource = self
        suggestionCollectionView.register(UINib(nibName: TenorSuggestionCell.identifer, bundle: nil), forCellWithReuseIdentifier: TenorSuggestionCell.identifer)
    }
    
    func setUpSearchBar() {
        searchBar.delegate = self
    }
}

extension GiphyVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == mainCollectionView) {
            return waterfallInfoData.count
        } else if (collectionView == suggestionCollectionView) {
            return suggestionData.count
        }
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == mainCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TenorCVCell.idetifier, for: indexPath) as! TenorCVCell
            cell.internetConnectionIsAvailable(isAvailable: true)
            
            if(waterfallInfoData.count<=indexPath.item) {
                cell.internetConnectionIsAvailable(isAvailable: false)
                return cell
            }
            
            let waterfallGifFileURLs = MemeMakerPickerFileManager.shared.getFilePath(folderName: cacheFolderName, fileURL: waterfallInfoData[indexPath.item].url)
            cell.tenorLoader.startAnimating()
            if FileManager.default.fileExists(atPath: waterfallGifFileURLs.path) {
                cell.loadTenorGIF(fileURL: waterfallGifFileURLs)
                return cell
            }
            
            let activeSearchTag = currentSearchTag
            MemeMakerPickerFileManager.shared.downloadAsset(url: waterfallInfoData[indexPath.item].url, folderName: cacheFolderName) { [weak self] cacheURL, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    guard let cell = collectionView.cellForItem(at: indexPath) as? TenorCVCell, activeSearchTag == self.currentSearchTag else {
                        return
                    }
                    
                    if let cacheURL = cacheURL {
                        cell.loadTenorGIF(fileURL: cacheURL)
                    } else {
                        cell.internetConnectionIsAvailable(isAvailable: false)
                    }
                }
            }
            
            return cell
        } else if(collectionView == suggestionCollectionView) {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TenorSuggestionCell.identifer, for: indexPath) as! TenorSuggestionCell
            cell.tenorSuggestionLabel.text = suggestionData[indexPath.item]
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == suggestionCollectionView) {
            if(indexPath.item >= suggestionData.count) { return }
            
            selectedSuggestionIndexPath = indexPath
            searchBar.text = suggestionData[indexPath.item]
            searchBarSearchButtonClicked(searchBar)
            
            UIView.animate(withDuration: 0.2, animations: {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            })
        } else if (collectionView == mainCollectionView) {
            let fileURL = MemeMakerPickerFileManager.shared.getFilePath(folderName: cacheFolderName, fileURL: waterfallInfoData[indexPath.item].url)
            if(MemeMakerPickerFileManager.shared.isFileExists(fileUrl: fileURL)) {
                print("Tenor item \(indexPath.item) exists")
                pickerDelegate?.memeMakerMediaPickerController(didFinishPickingWithGif: fileURL)
            }
            dismiss(animated: true)
        }
    }
}

extension GiphyVC: WaterfallLayoutDelegate {
    func waterfallLayout(_ layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item >= waterfallInfoData.count {
            return .zero
        }
        return waterfallInfoData[indexPath.item].size
    }
}

extension GiphyVC {
    func loadGIFURLs() {
        guard !isLoading else { return }
        let activeTag = currentSearchTag
        
        GiphyAPIManager.shared.fetchGIFs(query: defSearchTag, page: currentPage, baseURL: mainCollectionViewBaseURL, apiKey: mainCollectionViewApiKey) { [weak self] gifInfo, error in
            
            guard let self = self else { return }
            //checking wheather it is prev search url
            guard activeTag == self.currentSearchTag else { return }
            
            DispatchQueue.main.async {
                
                self.isLoading = false
                guard let gifInfo = gifInfo else { return }
                
                self.waterfallInfoData.append(contentsOf: gifInfo)
                self.mainCollectionView.reloadData()
                self.currentPage += 1
            }
        }
    }
}

extension GiphyVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        let needsFetch = indexPaths.contains { $0.row >= waterfallInfoData.count - 5 }
        if needsFetch && !isLoading {
            loadMoreData()
        }
    }
    
    private func loadMoreData() {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage += 1
        
        GiphyAPIManager.shared.fetchGIFs(query: currentSearchTag, page: currentPage, baseURL: mainCollectionViewBaseURL, apiKey: mainCollectionViewApiKey) { [weak self] gifInfo, error in
            guard let self = self else { return }
            guard let newGifInfo = gifInfo else {
                self.isLoading = false
                return
            }
            
            self.waterfallInfoData.append(contentsOf: newGifInfo)
            DispatchQueue.main.async {
                self.mainCollectionView.reloadData()
            }
            self.isLoading = false
        }
        
    }
}

extension GiphyVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == suggestionCollectionView{
            let font = UIFont.systemFont(ofSize: 16, weight: .medium)
            let size = (suggestionData[indexPath.item] as NSString).size(withAttributes: [.font: font])
            
            let width: CGFloat = size.width + 8
            let height: CGFloat = collectionView.bounds.height
            
            return CGSize(width: width, height: height)
        }
        
        return .zero
    }
}

extension GiphyVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            currentPage = 0
            waterfallInfoData.removeAll()
            currentSearchTag = defSearchTag
            searchDefTagInApiManager(defSearchTag, page: currentPage)
            
            if let selectedSuggestionIndexPath = selectedSuggestionIndexPath {
                suggestionCollectionView.deselectItem(at: selectedSuggestionIndexPath, animated: false)
            }
            print("default clips search")
        }
        
        debouncer.schedule({ [weak self] in
            self?.showSearchSuggestions(for: searchText.isEmpty ? self?.defSuggestionSearchTag ?? "" : searchText)
        })
        
    }
    
    //when user tapped on the search button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchBarText = searchBar.text else {
            print("empty search bar")
            return
        }
        
        currentPage = 0
        waterfallInfoData.removeAll()
        currentSearchTag = searchBarText
        searchInApiManager(searchBarText, page: currentPage)
        
    }
    
    func searchInApiManager(_ searchText: String, page: Int ) {
        GiphyAPIManager.shared.fetchGIFs(query: searchText, page: page, baseURL: mainCollectionViewBaseURL, apiKey: mainCollectionViewApiKey) { [weak self] gifInfo, error in
            DispatchQueue.main.async {
                guard
                    let self = self,
                    searchText == self.searchBar.text
                else {
                    return
                }
                
                guard let newGIFs = gifInfo else {
                    self.isLoading = false
                    return
                }
                
                
                self.waterfallInfoData.append(contentsOf: newGIFs)
                self.mainCollectionView.reloadData()
                self.isLoading = false
            }
        }
    }
    
    func searchDefTagInApiManager(_ searchText: String, page: Int ) {
        GiphyAPIManager.shared.fetchGIFs(query: searchText, page: page, baseURL: mainCollectionViewBaseURL, apiKey: mainCollectionViewApiKey) { [weak self] gifInfo, error in
            DispatchQueue.main.async {
                guard
                    let self = self,
                    let newGIFs = gifInfo
                else {
                    self?.isLoading = false
                    return
                }
                
                
                self.waterfallInfoData.append(contentsOf: newGIFs)
                self.mainCollectionView.reloadData()
                self.isLoading = false
            }
        }
    }
    func showSearchSuggestions(for searchText: String) {
        
        GiphySearchSuggestionApiManager.shared.fetchSearchSuggestions(query: defSuggestionSearchTag, baseURL: suggestionBaseURL, apiKey: suggestionApiKey) { [weak self] suggestions, error in
            
            guard let self = self else { return }
            if let suggestions = suggestions {
                self.suggestionData = suggestions
                DispatchQueue.main.async {
                    self.suggestionCollectionView.reloadData()
                }
            } else if let error = error {
                print("Error fetching suggestions: \(error.localizedDescription)")
            }
            
        }
    }
}
