//
//  ViewController.swift
//  CleanerApp
//
//  Created by Mohammad Noor on 21/11/24.
//

import UIKit
import Lottie
import LocalAuthentication

class CleanerTabItemController: UIViewController {
    @IBOutlet weak var collectionViewPageController: UIPageControl!
    
    @IBOutlet weak var cleanUpCollectionView: UICollectionView!
    
    @IBOutlet weak var middleViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pageControllerBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var circularProgressView: CircularProgressView!
    
    @IBOutlet weak var smartCleaningButtonView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateProgress()
        updateSceenCleaningButtonAnimation()
        setUpCollectionView()
        setUpMiddleView()
        //setUpPageController()
    }
    
    private func setUpPageController() {
        collectionViewPageController.addTarget(self, action: #selector(pageControlDidChange), for: .valueChanged)
        collectionViewPageController.numberOfPages = 3
    }
    
    @objc func pageControlDidChange() {
        let indexPath = IndexPath(item: collectionViewPageController.currentPage, section: 0)
        cleanUpCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
    private func setUpMiddleView() {
        if doesDeviceHaveHomeButton() {
            middleViewHeightConstraint.constant = 0
        }
        else{
            middleViewHeightConstraint.constant = 16
        }
    }
    
    private func updateProgress() {
        
        let availableStorage: CGFloat = 58
        let totalStorage: CGFloat = 128
        if(circularProgressView != nil && totalStorage != 0) {
            circularProgressView.progress = availableStorage / totalStorage
        }
    }
    
    func setUpCollectionView() {
        
        let layout = getCompositionalLayout()
        cleanUpCollectionView.collectionViewLayout = layout
        
        cleanUpCollectionView.delegate = self
        cleanUpCollectionView.dataSource = self
        
        
        let nib = UINib(nibName: "FeatureCollectionViewCell", bundle: nil)
        
        cleanUpCollectionView.register(nib, forCellWithReuseIdentifier: FeatureCollectionViewCell.identifier)
        
        cleanUpCollectionView.showsHorizontalScrollIndicator = false
        cleanUpCollectionView.backgroundColor = .systemBackground
    }
    
    func getCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            
            let screenWidth = UIScreen.main.bounds.width
            
            let proportionalHeight = (screenWidth / 414.0) * 156
            
            let proportionalSpacing = 14.0 //screenWidth * (20 / 414.0)
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize2 = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(proportionalHeight)
            )
            let group2 = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize2, subitem: item, count: 2)
            group2.interItemSpacing = .fixed(proportionalSpacing)
            
            let groupSize1 = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let group1 = NSCollectionLayoutGroup.vertical(layoutSize: groupSize1, subitem: group2, count: 2)
            group1.interItemSpacing = .fixed(proportionalSpacing)
            
            let section = NSCollectionLayoutSection(group: group1)
            section.interGroupSpacing = proportionalSpacing
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
                guard let self = self else { return }
                
                let pageIndex = Int(round(point.x / self.cleanUpCollectionView.frame.width))
                self.collectionViewPageController.currentPage = pageIndex
            }
            return section
        }
    }
    
    private func updateSceenCleaningButtonAnimation() {
        smartCleaningButtonView.contentMode = .scaleAspectFill
        smartCleaningButtonView.loopMode = .loop
        smartCleaningButtonView.animationSpeed = 0.7
        smartCleaningButtonView.play()
        
    }
    
    func doesDeviceHaveHomeButton() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if Face ID is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if context.biometryType == .faceID {
                // Device supports Face ID → no Home button
                return false
            } else if context.biometryType == .touchID {
                // Device supports Touch ID → has Home button
                return true
            }
        }
        // Default case for devices without Face ID or Touch ID
        return true
    }
    
}

extension CleanerTabItemController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeatureCollectionViewCell.identifier, for: indexPath) as? FeatureCollectionViewCell
        //cell.backgroundColor = .random
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
                // Create the storyboard instance and ensure that the storyboard ID matches what you set in the storyboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                // Instantiate the PhotoCleanUpController with the correct storyboard ID
                if let photoCleanUpVC = storyboard.instantiateViewController(withIdentifier: "PhotoCleanUpController") as? PhotoCleanUpController {
                    
                    // Push the view controller to the navigation stack
                    self.navigationController?.pushViewController(photoCleanUpVC, animated: true)
                }
            }
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0.4...1),
                       green: .random(in: 0.4...1),
                       blue: .random(in: 0.4...1),
                       alpha: 1
        )
    }
}

extension CleanerTabItemController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let halfWidth = (collectionView.bounds.width / 2) - 12
        return CGSize(width: halfWidth, height: halfWidth)
    }
}

