//
//  TemplateViewController.swift
//  QR Code Generator Release Edition
//
//  Created by Mohammad Noor on 12/11/24.
//

import UIKit
import SDWebImage

enum Section: Hashable {
    case first(Item?)
}

struct Item: Hashable {
    let uuid = UUID()
    var imageUrl: String?
}

class TemplateViewController: UIViewController {
    
    private var currentPage = 1
    private var isLoading = false
    private let itemsPerPage = 30
    
    @IBOutlet weak var headerCollectionView: UICollectionView!
    
    @IBOutlet weak var templateMainCollectionView: UICollectionView!
    
    private var sliderView: UIView!
    
    private let defImageURL =
    "https://pixabay.com/get/g4e0d6721f5f162f38695adb4f8bf16e20f98efb82420e1fa45e49fff034483e5adf689c6057e2cc25ebcfabb41dc870bd7ac54891a83db3eaf57ed88d4962df1_1280.jpg"
    
    var diffableDataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var sectionData: [Section] = []
    
    let tabs: [String] = ["Trending", "New", "Social", "Wi-Fi", "Event", "Business", "New", "Social", "Wi-Fi", "Event", "Business"]
    var selectedIndex: Int = 0
    let sliderWidth: CGFloat = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTabBarController()
        setUpHeaderCollectionView()
        setUpMainCollectionView()
        setUpDiffableDataSource()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUpSliderView()
        selectFirstItem()
        
    }
    
    func setUpTabBarController() {
        self.tabBarController?.delegate = self
    }
    
    func selectFirstItem() {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        self.headerCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        self.collectionView(self.headerCollectionView, didSelectItemAt: firstIndexPath)
    }
    
    func setUpSliderView() {
        if let firstCell = headerCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? TemplateHeaderCollectionViewCell {
            let xPosition = firstCell.frame.origin.x + (firstCell.frame.width - sliderWidth) / 2
            sliderView.frame = CGRect(x: xPosition, y: firstCell.frame.maxY - 4, width: sliderWidth, height: 2)
        }
    }
    
    
    func setUpHeaderCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        headerCollectionView.collectionViewLayout = layout
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        headerCollectionView.register(TemplateHeaderCollectionViewCell.self, forCellWithReuseIdentifier: TemplateHeaderCollectionViewCell.identifier)
        
        
        sliderView = UIView()
        sliderView.backgroundColor = .selectedBlue
        headerCollectionView.addSubview(sliderView)
    }
    
    func setUpMainCollectionView() {
        
        let layout = getCompositionalLayout()
        
        templateMainCollectionView.backgroundColor = .systemBackground
        templateMainCollectionView.collectionViewLayout = layout
        templateMainCollectionView.delegate = self
        //templateMainCollectionView.prefetchDataSource = self
        //templateMainCollectionView.dataSource = self
        templateMainCollectionView.register(TemplateMainCollectionViewCell.self,
                                            forCellWithReuseIdentifier: TemplateMainCollectionViewCell.self.description())
    }
}

extension TemplateViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateHeaderCollectionViewCell.identifier, for: indexPath) as! TemplateHeaderCollectionViewCell
        cell.titleLabel.text = tabs[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tabs.count
    }
    
}

extension TemplateViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = tabs[indexPath.row]
        let width = text.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16)]).width + 16 // Add padding
        return CGSize(width: width, height: collectionView.frame.height)
    }
}

extension TemplateViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == headerCollectionView) {
            selectedIndex = indexPath.row
            
            if let cell = collectionView.cellForItem(at: indexPath) as? TemplateHeaderCollectionViewCell {
                let xPosition = cell.frame.midX
                UIView.animate(withDuration: 0.2, animations: {
                    self.sliderView.center.x = xPosition
                    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                })
            }
            
            currentPage = 1
            
            PixabayAPIManager.shared.fetchData(searchTag: tabs[indexPath.item], perPage: itemsPerPage) { [weak self] urls in
                guard let self = self else { return }
                let items = urls.map { Item(imageUrl: $0) }
                self.sectionData = items.map { Section.first($0) }
                self.updateDataSource()
                if self.templateMainCollectionView.numberOfSections > 0 {
                    self.templateMainCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                }
            }
        }
        
    }
    
    //pagination
    //    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //        if collectionView == templateMainCollectionView && indexPath.row == sectionData.count - 5 && !isLoading {
    //            loadMoreData()
    //        }
    //    }
    
    
}

extension TemplateViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard collectionView == templateMainCollectionView else { return }
        
        let needsFetch = indexPaths.contains { $0.row >= sectionData.count - 5 }
        
        if needsFetch && !isLoading {
            loadMoreData()
        }
    }
    
    private func loadMoreData() {
        guard !isLoading else { return }
        isLoading = true
        
        currentPage += 1
        //print("CURRENT PAGE::::", currentPage)
        PixabayAPIManager.shared.fetchData(searchTag: tabs[selectedIndex], page: currentPage, perPage: itemsPerPage) { [weak self] urls in
            guard let self = self else { return }
            guard !urls.isEmpty else {
                self.isLoading = false
                return
            }
            let newItems = urls.map { Item(imageUrl: $0) }
            self.sectionData.append(contentsOf: newItems.map { Section.first($0) })
            self.updateDataSource()
            self.isLoading = false
        }
    }
    
}

extension TemplateViewController {
    func getCompositionalLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self] index, env in
            return self?.getSectionFor(section: index)
        }
        return layout
    }
    
    private func getSectionFor(section: Int) -> NSCollectionLayoutSection {
        
        
        return createSection(itemWidth: .fractionalWidth(1/3),
                             itemHeight: .absolute(100),
                             interItemSpacing: 10,
                             groupWidth: .fractionalWidth(1),
                             groupHeight: .absolute(100),
                             interGroupSpacing: 10,
                             sectionInsets: .init(top: 0, leading: 10, bottom: 10, trailing: 10),
                             headerHeight: .absolute(50))
    }
    
    private func createSection(itemWidth: NSCollectionLayoutDimension,
                               itemHeight: NSCollectionLayoutDimension,
                               interItemSpacing: CGFloat = 0,
                               groupWidth: NSCollectionLayoutDimension,
                               groupHeight: NSCollectionLayoutDimension,
                               interGroupSpacing: CGFloat = 0,
                               sectionInsets: NSDirectionalEdgeInsets = .zero,
                               scrollBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none,
                               headerHeight: NSCollectionLayoutDimension? = nil,
                               footerHeight: NSCollectionLayoutDimension? = nil) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: itemWidth, heightDimension: itemHeight)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: groupHeight), subitems: [item])
        group.interItemSpacing = .fixed(interItemSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = interGroupSpacing
        
        section.orthogonalScrollingBehavior = scrollBehavior
        section.contentInsets = sectionInsets
        
        return section
    }
    
    private func emptySection(_ height: CGFloat = 0) -> NSCollectionLayoutSection {
        return createSection(itemWidth: .fractionalWidth(1), itemHeight: .absolute(height), groupWidth: .fractionalWidth(1), groupHeight: .fractionalHeight(height))
    }
}

extension TemplateViewController {
    
    private func setUpDiffableDataSource() {
        createDataSource()
        
        if(tabs.count <= 0){
            return
        }
        
        templateMainCollectionView.prefetchDataSource = self
    }
    
    private func createDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: templateMainCollectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateMainCollectionViewCell.self.description(), for: indexPath) as! TemplateMainCollectionViewCell
            cell.configure(with: itemIdentifier.imageUrl ?? self?.defImageURL)
            return cell
        })
    }
    
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.first(nil)])
        let items = sectionData.compactMap { section in
            switch section {
            case .first(let item):
                return item
            }
        }
        snapshot.appendItems(items, toSection: .first(nil))
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.diffableDataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }
}

extension TemplateViewController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController != self {
            clearCache()
        }
    }
    
    private func clearCache() {
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk(onCompletion: {
            print("Cache cleared")
        })
    }
}
