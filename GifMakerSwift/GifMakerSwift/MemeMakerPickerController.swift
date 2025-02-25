//
//  ViewController.swift
//  CollectionTabView
//
//  Created by Mohammad Noor on 16/1/25.
//

import UIKit

protocol MemeMakerPickerControllerDelegate: AnyObject {
    func memeMakerMediaPickerController(didFinishPickingWithImage image: UIImage)
    func memeMakerMediaPickerController(didFinishPickingWithVideo videoURL: URL)
    func memeMakerMediaPickerController(didFinishPickingWithGif gifURL: URL)
}

class MemeMakerPickerController: UIViewController {
    
    weak var pagerVC: MemeMakerRootPageViewController?
    weak var delegate: MemeMakerPickerControllerDelegate?
    
    @IBOutlet weak var selectViewControllerCollectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    private var loadOnce: Bool = false
    
    var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    let navTitles: [String] = MemeMakerPiclerOptions.allCases.map {
        switch $0 {
        case .libraryImagePicker: return "Library"
        case .clips: return "Clips"
        case .tenor: return "Tenor"
        case .giphy: return "Giphy"
        case .web: return "Web"
        case .reddit: return "Reddit"
        case .imgurPic: return "Imgur Pic"
        case .imgurVid: return "Imgur Vid"
        case .camera: return "Camera"
        case .files: return "Files"
        }
    }
    let imageNames: [String] = MemeMakerPiclerOptions.allCases.map {
        switch $0 {
        case .libraryImagePicker: return "icLibrary"
        case .clips: return "icClips"
        case .tenor: return "icTenor"
        case .giphy: return "icGiphy"
        case .web: return "icWeb"
        case .reddit: return "icReddit"
        case .imgurPic: return "icImgurPic"
        case .imgurVid: return "icImgurVid"
        case .camera: return "icCamera"
        case .files: return "icFiles"
        }
    }
    let imageTextLabels: [String] = MemeMakerPiclerOptions.allCases.map {
        switch $0 {
        case .libraryImagePicker: return "Library"
        case .clips: return "Clips"
        case .tenor: return "Tenor"
        case .giphy: return "Giphy"
        case .web: return "Web"
        case .reddit: return "Reddit"
        case .imgurPic: return "Imgur Pic"
        case .imgurVid: return "Imgur Vid"
        case .camera: return "Camera"
        case .files: return "Files"
        }
    }
    
    var images: [UIImage] {
        imageNames.compactMap { UIImage(named: $0)}
    }
    var curChildVC : UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBar()
        
        view.window?.overrideUserInterfaceStyle = .dark
        setSelectViewControllerCollectionView()
    }
    
    func centerCollectionViewIfNeeded() {
        let leftInset = (self.view.bounds.width - selectViewControllerCollectionView.contentSize.width)/2
        if leftInset > 0 {
            selectViewControllerCollectionView.contentInset = UIEdgeInsets(
                top: 0,
                left: leftInset,
                bottom: 0,
                right: 0
            )
        }

    }
    
    func setNavBar() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        cancelButton.setTitleTextAttributes([.foregroundColor: UIColor(named: "colSelectedIconYello")!], for: .normal)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if(UIDevice.isIPad) {
            centerCollectionViewIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {[weak self] in
            if let self, loadOnce == false {
                selectIndex(at: IndexPath(item: 0, section: 0))
                loadOnce = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickerPager",
           let pagerVC = segue.destination as? MemeMakerRootPageViewController {
            self.pagerVC = pagerVC
            pagerVC.pickerDelegate = self.delegate
            pagerVC.fileDelegate = self
        }
    }
    
    
    func selectIndex(at indexPath: IndexPath) {
        
        selectViewControllerCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        collectionView(selectViewControllerCollectionView, didSelectItemAt: indexPath)
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
        guard let pagerVC = self.pagerVC else { return }
        print("Switching to view controller at index:", index)
        
        pagerVC.switchToViewController(at: index)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
}

extension MemeMakerPickerController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectionCollectionViewCell.identifier, for: indexPath) as! SelectionCollectionViewCell
        
        cell.imageLabel.text = imageTextLabels[indexPath.item]
        cell.imageIcon.image = images[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switchViewController(at: indexPath.item)
        self.title = navTitles[indexPath.item]
        
    }
}

extension MemeMakerPickerController: MemeMakerFilePickerControllerDelegate {
    func MemeMakerFilePickerControllerDelegate(selectItemAt index: Int) {
        selectViewControllerCollectionView.selectItem(
            at: IndexPath(item: index, section: 0),
            animated: true,
            scrollPosition: .centeredHorizontally
        )
        //        selectViewControllerCollectionView.delegate?.collectionView?(selectViewControllerCollectionView, didSelectItemAt: IndexPath(item: index, section: 0))
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


//        curChildVC?.willMove(toParent: nil)
//        curChildVC?.view.removeFromSuperview()
//        curChildVC?.removeFromParent()
//
//        let newVC: UIViewController
//
//        if index == 0 {
//            let imagePicker = UIImagePickerController()
//            //imagePicker.delegate = self
//            imagePicker.sourceType = .photoLibrary
//            imagePicker.mediaTypes = ["public.image", "public.movie"]
//            imagePicker.allowsEditing = false
//            imagePicker.overrideUserInterfaceStyle = .dark
//
//            newVC = imagePicker
//        } else {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//            newVC = storyboard.instantiateViewController(withIdentifier: viewControllerNames[index])
//        }
//
//
//        addChild(newVC)
//        newVC.view.frame = containerView.bounds
//        containerView.addSubview(newVC.view)
//        newVC.didMove(toParent: self)
//
//        curChildVC = newVC

//
//    func setNavbarSize() {
//        if let navBar = navigationItem.titleView as? UINavigationBar {
//            var frame = navBar.frame
//            frame.size.height = 20
//            navBar.frame = frame
//        }
//    }


