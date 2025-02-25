
import UIKit

class ProjectViewController: UIViewController {
    
    private var currentPage = 1
    private var isLoading = false
    private let itemsPerPage = 30
    
    private var selectedIndex: Int = 0
    
    @IBOutlet weak var projectSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var projectCollectionView: UICollectionView!
    
    private let defImageURL =
    "https://pixabay.com/get/g4e0d6721f5f162f38695adb4f8bf16e20f98efb82420e1fa45e49fff034483e5adf689c6057e2cc25ebcfabb41dc870bd7ac54891a83db3eaf57ed88d4962df1_1280.jpg"
    
    let projects: [String] = ["Generated", "Scanned"]
    
    var diffableDataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var sectionData: [Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpProjectCollectionView()
        setUpDiffableDataSource()
        //clickSegControl()
    }
    
    func clickSegControl() {
        projectSegmentedControl.selectedSegmentIndex = 0
        projectSegmentedControlAction(projectSegmentedControl)
    }
    
    @IBAction func projectSegmentedControlAction(_ sender: UISegmentedControl) {
        
        switch projectSegmentedControl.selectedSegmentIndex {
            
        case 0:
            PixabayAPIManager.shared.fetchData(searchTag: "Generated") { [weak self] urls in
                
                guard let self = self else { return }
                
                currentPage = 1
                self.selectedIndex = 0
                
                let items = urls.map { Item(imageUrl: $0) }
                self.sectionData = items.map { Section.first($0) }
                
                if(self.projectCollectionView.numberOfSections > 0) {
                    self.projectCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: false)
                }
                
                self.updateDataSource()
            }
            
        case 1:
            PixabayAPIManager.shared.fetchData(searchTag: "Scanned") { [weak self] urls in
                
                guard let self = self else { return }
                
                self.currentPage = 1
                self.selectedIndex = 1
                
                let items = urls.map { Item(imageUrl: $0) }
                self.sectionData = items.map { Section.first($0) }
                
                if(self.projectCollectionView.numberOfSections > 0) {
                    self.projectCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: false)
                }
                
                self.updateDataSource()
            }
            
        default:
            break
        }
    }
    
    func setUpProjectCollectionView() {
        
        let layout = getCompositionalLayout()
        
        projectCollectionView.backgroundColor = .systemBackground
        projectCollectionView.collectionViewLayout = layout
        
        projectCollectionView.delegate = self
        //dashBoardCollectionView.dataSource = self
        
        projectCollectionView.register(TemplateMainCollectionViewCell.self,
                                       forCellWithReuseIdentifier: TemplateMainCollectionViewCell.self.description())
    }
    
    
    
}
extension ProjectViewController: UICollectionViewDelegate {
    //pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == projectCollectionView && indexPath.row == sectionData.count - 1 && !isLoading {
                loadMoreData()
            }
        }
        
    private func loadMoreData() {
        guard !isLoading else { return }
        isLoading = true

        currentPage += 1
        PixabayAPIManager.shared.fetchData(searchTag: projects[selectedIndex], page: currentPage, perPage: itemsPerPage) { [weak self] urls in
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

extension ProjectViewController {
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

extension ProjectViewController {
    
    private func setUpDiffableDataSource() {
        createDataSource() // Initialize diffable data source if not already done
        
        // Fetch images based on the current search tag
        PixabayAPIManager.shared.fetchData(searchTag: "Generated") { [weak self] urls in
            guard let self = self else { return }
            let items = urls.map { Item(imageUrl: $0) }
            self.sectionData = items.map { Section.first($0) }
            self.updateDataSource()
        }
    }
    
    private func createDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: projectCollectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
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
