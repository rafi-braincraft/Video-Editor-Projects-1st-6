//
//  ViewController.swift
//  RujiRuti
//
//  Created by Mohammad Noor on 4/11/24.
//
//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


import UIKit

enum Section: Hashable {
    case first(Item?)
    case second(Item?)
    case third(Item?)
}

struct Item: Hashable {
    let uuid = UUID()
    var imageUrl: String?
}

class ViewController: UIViewController {
    
    @IBOutlet weak var dashBoardCollectionView: UICollectionView!
    
    @IBOutlet weak var searchBarView: UISearchBar!
    
    var searchTag1 = "Football"
    var searchTag2 = "Cricket"
    var searchTag3 = "Rugbi"
    
    private let defImageURL =
    "https://pixabay.com/get/g4e0d6721f5f162f38695adb4f8bf16e20f98efb82420e1fa45e49fff034483e5adf689c6057e2cc25ebcfabb41dc870bd7ac54891a83db3eaf57ed88d4962df1_1280.jpg"
    
    var diffableDataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    private var sectionData: [[Section]] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUpCollectionView()
        setUpDiffableDataSource()
        setUpSearchView()
    }
    
    func setUpSearchView() {
        searchBarView.delegate = self
    }
    
    @IBAction func navDeleteItem(_ sender: UIBarButtonItem) {
        
        if sectionData[2].count > 0 {
            sectionData[2].removeFirst()
        }
        
        updateDataSource()
    }
    
    
    @IBAction func navAddItem(_ sender: UIBarButtonItem) {
        
        let newItem = Section.third(Item(imageUrl: defImageURL))
        sectionData[2].append(newItem)
        updateDataSource()
    }
    
    
    func setUpCollectionView() {
        
        let layout = getCompositionalLayout()
        
        dashBoardCollectionView.backgroundColor = .systemBackground
        dashBoardCollectionView.collectionViewLayout = layout
        
        dashBoardCollectionView.delegate = self
        //dashBoardCollectionView.dataSource = self
        
        dashBoardCollectionView.register(dashBoardCollectionViewCell.self,
                                         forCellWithReuseIdentifier: dashBoardCollectionViewCell.self.description())
        dashBoardCollectionView.register(dashSectionHeaderCell.self,
                                         forSupplementaryViewOfKind: dashSectionHeaderCell.self.description(),
                                         withReuseIdentifier: dashSectionHeaderCell.self.description())
        dashBoardCollectionView.register(dashSectionFooterCell.self,
                                         forSupplementaryViewOfKind: dashSectionFooterCell.self.description(),
                                         withReuseIdentifier: dashSectionFooterCell.self.description())
    }
    
}


extension ViewController: UICollectionViewDelegate {
    
    func getCompositionalLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self] index, env in
            return self?.getSectionFor(section: index)
        }
        return layout
    }
    
    private func getSectionFor(section: Int) -> NSCollectionLayoutSection {
        
        let sectionEnum = diffableDataSource.sectionIdentifier(for: section) //when i need the corresponding sectionIdentifier of the diffableDatasource
        
        switch sectionEnum {
        case .first:
            return createSection(itemWidth: .fractionalWidth(1),
                                 itemHeight: .absolute(200),
                                 groupWidth: .fractionalWidth(1),
                                 groupHeight: .absolute(200),
                                 scrollBehavior: .groupPagingCentered)
        case .second:
            return createSection(itemWidth: .fractionalWidth(1/3),
                                 itemHeight: .absolute(100),
                                 interItemSpacing: 10,
                                 groupWidth: .fractionalWidth(1),
                                 groupHeight: .absolute(100),
                                 interGroupSpacing: 10,
                                 sectionInsets: .init(top: 0, leading: 10, bottom: 10, trailing: 10),
                                 scrollBehavior: .continuous,
                                 headerHeight: .absolute(50))
        case .third:
            return createSection(itemWidth: .fractionalWidth(1/3),
                                 itemHeight: .absolute(100),
                                 interItemSpacing: 10,
                                 groupWidth: .fractionalWidth(1),
                                 groupHeight: .absolute(100),
                                 interGroupSpacing: 10,
                                 sectionInsets: .init(top: 0, leading: 10, bottom: 10, trailing: 10),
                                 headerHeight: .absolute(50))
        default:
            break
        }
        
        return emptySection()
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
        
        section.boundarySupplementaryItems = []
        if let headerHeight = headerHeight {
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                                        heightDimension: headerHeight),
                                                                     elementKind: dashSectionHeaderCell.self.description(),
                                                                     alignment: .top)
            section.boundarySupplementaryItems.append(header)
        }
        
        if let footerHeight = footerHeight {
            
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                                        heightDimension: footerHeight),
                                                                     elementKind: dashSectionFooterCell.self.description(),
                                                                     alignment: .bottom)
            section.boundarySupplementaryItems.append(footer)
        }
        
        return section
    }
    
    private func emptySection(_ height: CGFloat = 0) -> NSCollectionLayoutSection {
        return createSection(itemWidth: .fractionalWidth(1), itemHeight: .absolute(height), groupWidth: .fractionalWidth(1), groupHeight: .fractionalHeight(height))
    }
}


extension ViewController {
    private func setUpDiffableDataSource() {
        
        sectionData = [[Section.first(Item(imageUrl: defImageURL))], [Section.second(Item(imageUrl: defImageURL))], [Section.third(Item(imageUrl: defImageURL))]]
        
        APIManager.shared.fetchData(searchTag: searchTag1) { [weak self] urls in
            guard let self = self else { return }
            let items = urls.map { Item(imageUrl: $0) }
            self.sectionData[0] = items.map { Section.first($0) }
            self.updateDataSource()
        }
        
        APIManager.shared.fetchData(searchTag: searchTag2) { [weak self] urls in
            guard let self = self else { return }
            let items = urls.map { Item(imageUrl: $0) }
            self.sectionData[1] = items.map { Section.second($0) }
            self.updateDataSource()
        }
        
        APIManager.shared.fetchData(searchTag: searchTag3) { [weak self] urls in
            guard let self = self else { return }
            let items = urls.map { Item(imageUrl: $0) }
            self.sectionData[2] = items.map { Section.third($0) }
            self.updateDataSource()
        }
        
        createDataSource()
        updateDataSource()
        // Load images for the first and second sections
        
    }
    
    private func createDataSource() {
        
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: dashBoardCollectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dashBoardCollectionViewCell.self.description(), for: indexPath) as! dashBoardCollectionViewCell
            
            let curSecData = self?.sectionData[indexPath.section][indexPath.item]
            switch curSecData {
            case .first(let data):
                cell.configure(with: data?.imageUrl ?? self?.defImageURL)
            case .second(let data):
                cell.configure(with: data?.imageUrl ?? self?.defImageURL)
            case .third(let data):
                cell.configure(with: data?.imageUrl ?? self?.defImageURL)
                
            default:
                cell.configure(with: self?.defImageURL)
            }
            
            
            //cell.backgroundColor = self?.sectionDataSource[indexPath.section][indexPath.item]
            //cell.layer.borderWidth = 1.0
            //cell.layer.borderColor = UIColor.black.cgColor
            return cell
        })
        
        diffableDataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            
            guard let self = self else { return UICollectionReusableView() }
            
            if kind == dashSectionHeaderCell.self.description() {
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: kind,
                                                                           for: indexPath) as! dashSectionHeaderCell
                switch indexPath.section {
                case 0:
                    cell.configure(title: self.searchTag1)
                case 1:
                    cell.configure(title: self.searchTag2)
                case 2:
                    cell.configure(title: self.searchTag3)
                default:
                    cell.configure(title: "")
                }
                
                cell.backgroundColor = .systemBackground
                
                return cell
            }
            
            if kind == dashSectionFooterCell.self.description() {
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: kind,
                                                                           for: indexPath) as! dashSectionFooterCell
                cell.backgroundColor = .red
                return cell
            }
            
            return UICollectionReusableView()
            
        }
    }
    
    private func updateDataSource() {
        
        var snapShot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        for section in sectionData {
            
            if (section.count == 0) {
                continue
            }
            
            guard let sectionName = section.first else {continue}
            
            var items = [Item]()
            
            for item in section { //item is a enum of section type
                switch item {
                case .first(let data):
                    if let data = data {
                        items.append(data)
                    }
                    
                case .second(let data):
                    if let data = data {
                        items.append(data)
                    }
                    
                case .third(let data):
                    if let data = data {
                        items.append(data)
                    }
                }
            }
            
            print("Appending section: \(sectionName) with items: \(items.count)")
            snapShot.appendSections([sectionName])
            if items.isEmpty {
                print("No items to append for section: \(sectionName)")
            } else {
                snapShot.appendItems(items, toSection: sectionName)
            }
        }
        
        //diffableDataSource.apply(snapShot, animatingDifferences: true)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) { // Set your desired duration here
                self.diffableDataSource.apply(snapShot, animatingDifferences: true)
            }
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //searchTag3 = searchText
        showSearchSuggestions(for: searchText)
        
        searchTag3 = searchBar.text ?? searchTag3
        
        APIManager.shared.fetchData(searchTag: searchTag3) { [weak self] urls in
            guard let self = self else { return }
            let items = urls.map { Item(imageUrl: $0) }
            self.sectionData[2] = items.map { Section.third($0) }
            self.updateDataSource()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchTag3 = searchBar.text ?? searchTag3
        
        APIManager.shared.fetchData(searchTag: searchTag3) { [weak self] urls in
            guard let self = self else { return }
            let items = urls.map { Item(imageUrl: $0) }
            self.sectionData[2] = items.map { Section.third($0) }
            self.updateDataSource()
        }
        
    }
    
    func showSearchSuggestions(for searchText: String) {
        let suggestions = ["Football", "Root", "Basketball", "Cricket", "Tennis", "Rugby", "Soccer"].filter {
            $0.lowercased().contains(searchText.lowercased())
        }
        
        print("Suggestions: \(suggestions)")
    }
}
