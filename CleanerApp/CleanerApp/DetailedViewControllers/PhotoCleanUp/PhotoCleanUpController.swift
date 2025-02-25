//
//  PhotoCleanUpController.swift
//  CleanerApp
//
//  Created by Mohammad Noor on 12/12/24.
//

//
//  PhotoCleanUpController.swift
//  CleanerApp
//
//  Created by Mohammad Noor on 12/12/24.
//

import UIKit

enum Section: Hashable {
    case first(Item?)
}

struct Item: Hashable {
    let uuid = UUID()
    var imageUrl: String?
}

class PhotoCleanUpController: UIViewController {
    var selectedImageURL: String?
    
    @IBOutlet weak var countTitleTopView: TopView!
    @IBOutlet weak var detailsCollectionView: UICollectionView!
    @IBOutlet weak var headerCollectionView: UICollectionView!
    
    private var sliderView: UIView!
    private let sliderWidth: CGFloat = 30
    
    private let defImageURL =
    "https://pixabay.com/get/g4e0d6721f5f162f38695adb4f8bf16e20f98efb82420e1fa45e49fff034483e5adf689c6057e2cc25ebcfabb41dc870bd7ac54891a83db3eaf57ed88d4962df1_1280.jpg"
    
    var diffableDataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var sectionData: [Section] = []
    
    let tabs: [String] = ["Agra", "New York", "Washington", "Sydney", "Istanbul", "Abu Dhabi", "Las Vegas", "London", "Beijing", "Barcelona", "Madrid"]
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTopView()
        setUpHeaderCollectionView()
        setUpDetailsCollectionView()
        setUpDiffableDataSource()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpSliderView()
        selectFirstTab()
    }
    
    func setUpTopView() {
        view.backgroundColor = .systemBackground
        title = "Photo Clean Up"
        
        countTitleTopView.setUpdateCountCompletionHandler(for: self)
//        countTitleTopView.actionButtonHandler = { [weak self] in
//                guard let self = self else { return }
//                
//                guard let imageUrl = self.selectedImageURL else {
//                    print("No image selected")
//                    return
//                }
//                
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                if let photoPropertiesVC = storyboard.instantiateViewController(withIdentifier: "PhotoPropertiesViewController") as? PhotoPropertiesViewController {
//                    
//                    photoPropertiesVC.imageUrl = imageUrl
//                    
//                    self.navigationController?.pushViewController(photoPropertiesVC, animated: true)
//                }
//            }
        countTitleTopView.delegate = self
    }
    
    func selectFirstTab() {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        self.headerCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        self.collectionView(self.headerCollectionView, didSelectItemAt: firstIndexPath)
    }
    
    func setUpSliderView() {
        if let firstCell = headerCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? HeaderCollectionViewCell {
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
        headerCollectionView.register(HeaderCollectionViewCell.self, forCellWithReuseIdentifier: HeaderCollectionViewCell.identifier)
        
        
        sliderView = UIView()
        sliderView.backgroundColor = .customBlue
        headerCollectionView.addSubview(sliderView)
    }
    
    func setUpDetailsCollectionView() {
        
        let layout = getCompositionalLayout()
        
        detailsCollectionView.backgroundColor = .systemBackground
        detailsCollectionView.collectionViewLayout = layout
        detailsCollectionView.delegate = self
        //templateMainCollectionView.dataSource = self
        detailsCollectionView.register(DetailsCollectionViewCell.self,
                                       forCellWithReuseIdentifier: DetailsCollectionViewCell.self.description())
    }
}

extension PhotoCleanUpController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderCollectionViewCell.identifier, for: indexPath) as! HeaderCollectionViewCell
        cell.titleLabel.text = tabs[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tabs.count
    }
    
}

extension PhotoCleanUpController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = tabs[indexPath.row]
        let width = text.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16)]).width + 16 // Add padding
        return CGSize(width: width, height: collectionView.frame.height)
    }
}

extension PhotoCleanUpController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == headerCollectionView) {
            selectedIndex = indexPath.row
            
            if let cell = collectionView.cellForItem(at: indexPath) as? HeaderCollectionViewCell {
                let xPosition = cell.frame.midX
                UIView.animate(withDuration: 0.2, animations: {
                    self.sliderView.center.x = xPosition
                    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                })
            }
            
            
            
            PixabayAPIManager.shared.fetchData(searchTag: tabs[indexPath.item]) { [weak self] urls in
                
                guard let self = self else { return }
                
                let items = urls.map { Item(imageUrl: $0) }
                self.sectionData = items.map { Section.first($0) }
                
                self.countTitleTopView.updateCountCompletion?(items.count-indexPath.item)
                
                self.updateDataSource()
            }
        }
        
        if collectionView == detailsCollectionView {
                let selectedItem = diffableDataSource.itemIdentifier(for: indexPath)
                selectedImageURL = selectedItem?.imageUrl
            }
        
    }
    
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
        
        
        let item221 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2)))
        item221.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let item31 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        item31.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let group22 = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1)), subitems: [item221])
        
        let item21 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1)))
        item21.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let group2 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2)), subitems: [item21, group22])
        
        let group3 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/4)), subitems: [item31])
        
        let item41 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1)))
        item41.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        let group4 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/4)), subitems: [item41])
        
        let contLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let containerGroup = NSCollectionLayoutGroup.vertical(layoutSize: contLayoutSize, subitems: [group2, group3,group4])
        let section = NSCollectionLayoutSection(group: containerGroup)
        
        return section
    }
    
    private func emptySection(_ height: CGFloat = 0) -> NSCollectionLayoutSection {
        return createSection(itemWidth: .fractionalWidth(1), itemHeight: .absolute(height), groupWidth: .fractionalWidth(1), groupHeight: .fractionalHeight(height))
    }
}

extension PhotoCleanUpController {
    
    private func setUpDiffableDataSource() {
        createDataSource()
        
        if(tabs.count <= 0){
            return
        }
        
    }
    
    private func createDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: detailsCollectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailsCollectionViewCell.self.description(), for: indexPath) as! DetailsCollectionViewCell
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

extension PhotoCleanUpController: TopViewDelegate {
    func topView(_ topView: TopView) {
        guard let selectedURL = selectedImageURL else {
            print("No image selected")
            return
        }
        
        // Navigate to PhotoPropertiesViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let photoPropertiesVC = storyboard.instantiateViewController(withIdentifier: "PhotoPropertiesViewController") as? PhotoPropertiesViewController {
            
            photoPropertiesVC.imageUrl = selectedURL  // Pass the selected image URL
            self.navigationController?.pushViewController(photoPropertiesVC, animated: true)
        }
    }
}
