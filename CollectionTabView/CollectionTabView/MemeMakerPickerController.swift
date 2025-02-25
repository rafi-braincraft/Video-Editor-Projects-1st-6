//
//  ViewController.swift
//  CollectionTabView
//
//  Created by Mohammad Noor on 16/1/25.
//

import UIKit

class MemeMakerPickerController: UIViewController {
    @IBOutlet weak var selectViewControllerCollectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    private var loadOnce: Bool = false
    
    var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    let imageNames: [String] = ["icLibrary", "icClips", "icTenor", "icGiphy", "icMemes", "icReddit", "icImgurPic", "icImgurVid", "icCamera", "icFiles"]
    let imageTextLabels: [String] = ["Library", "Clips", "Tenor", "Giphy", "Memes", "Reddit", "ImgurPic", "ImgurVid", "Camera", "Files"]
    let viewControllerNames: [String] = ["LibraryVC", "ClipsVC", "TenorVC", "GiphyVC", "MemesVC", "RedditVC", "ImgurPicVC", "ImgurVidVC", "CameraVC", "FilesVC"]
    
    var images: [UIImage] {
        imageNames.compactMap { UIImage(named: $0)}
    }
    var curChildVC : UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.window?.overrideUserInterfaceStyle = .dark
        setSelectViewControllerCollectionView()
       // setValue(CustomNavBar(), forKey: "navigationBar")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {[weak self] in
            if let self, loadOnce == false {
                selectFirstIndex()
                loadOnce = true
            }
        }
    }
    
    func selectFirstIndex() {

        let firstIndexPath = IndexPath(item: 0, section: 0)
        selectViewControllerCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        collectionView(selectViewControllerCollectionView, didSelectItemAt: firstIndexPath)
    }
    
    func setSelectViewControllerCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        selectViewControllerCollectionView.collectionViewLayout = layout
        selectViewControllerCollectionView.delegate = self
        selectViewControllerCollectionView.dataSource = self
        
        let nib = UINib(nibName: "SelectionCollectionViewCell", bundle: nil)
        selectViewControllerCollectionView.register(nib, forCellWithReuseIdentifier: SelectionCollectionViewCell.identifier)
    }
    
    func switchViewController(at index: Int) {
        curChildVC?.willMove(toParent: nil)
        curChildVC?.view.removeFromSuperview()
        curChildVC?.removeFromParent()
        
        let newVC: UIViewController
        
        if index == 0 {
            let imagePicker = UIImagePickerController()
            //imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            imagePicker.allowsEditing = false
            imagePicker.overrideUserInterfaceStyle = .dark
            
            newVC = imagePicker
            
            navigationController?.isNavigationBarHidden = true
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            newVC = storyboard.instantiateViewController(withIdentifier: viewControllerNames[index])
            
            navigationController?.isNavigationBarHidden = false
        }
        
        
        addChild(newVC)
        newVC.view.frame = containerView.bounds
        containerView.addSubview(newVC.view)
        newVC.didMove(toParent: self)
        
        curChildVC = newVC
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //centerCollectionViewIfNeeded()
        //setNavbarSize()
        
    }
    
    func setNavbarSize() {
        if let navBar = navigationItem.titleView as? UINavigationBar {
            var frame = navBar.frame
            frame.size.height = 20
            navBar.frame = frame
        }
    }
    
    func centerCollectionViewIfNeeded() {
        let leftInset = (UIScreen.main.bounds.width - selectViewControllerCollectionView.contentSize.width)/2
        if leftInset > 0 {
            selectViewControllerCollectionView.contentInset = UIEdgeInsets(
                top: 0,
                left: leftInset,
                bottom: 0,
                right: 0
            )
        }
        
    }
    
}

extension MemeMakerPickerController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectionCollectionViewCell.identifier, for: indexPath) as! SelectionCollectionViewCell
        
        cell.configure(imageTextLabels[indexPath.item] , image: images[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switchViewController(at: indexPath.item)
        
    }
}

extension MemeMakerPickerController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (52.0) * screenWidth / 414.0
        let height = collectionView.frame.height
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}

class CustomNavBar: UINavigationBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize = super.sizeThatFits(size)
        newSize.height = 44
        return newSize
    }
}

//extension MemeMakerPickerController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let selectedImage = info[.originalImage] as? UIImage {
//            print("Selected image: \(selectedImage)")
//        } else if let selectedVideoURL = info[.mediaURL] as? URL{
//            print("Selected video: \(selectedVideoURL)")
//
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func presentMediaPicker() {
////        let imagePicker = UIImagePickerController()
////        imagePicker.delegate = self
////        imagePicker.sourceType = .photoLibrary
////        imagePicker.mediaTypes = ["public.image", "public.movie"]
////        imagePicker.allowsEditing = false
////        present(imagePicker, animated: false, completion: nil)
//    }
//}
