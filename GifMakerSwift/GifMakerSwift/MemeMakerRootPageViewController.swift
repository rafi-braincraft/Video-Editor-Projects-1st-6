//
//  MeemMakerRootPageViewController.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 28/1/25.
//

import UIKit
import MobileCoreServices

protocol MemeMakerFilePickerControllerDelegate: AnyObject {
    func MemeMakerFilePickerControllerDelegate(selectItemAt index: Int)
}

class MemeMakerRootPageViewController: UIPageViewController {
    
    weak var pickerDelegate: MemeMakerPickerControllerDelegate?
    weak var fileDelegate: MemeMakerFilePickerControllerDelegate?
    
    var viewControllersList: [UIViewController] = []
    let selectedYelloColor = UIColor(named: "colSelectedIconYello")!
    var prevSelectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPagerController()
    }
    
    func setUpPagerController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewControllersList = MemeMakerPiclerOptions.allCases.map { option in
            
            let childVC = (option == MemeMakerPiclerOptions.libraryImagePicker || option == MemeMakerPiclerOptions.files || option == MemeMakerPiclerOptions.camera) ? nil : storyboard.instantiateViewController(withIdentifier: option.rawValue)
            
            switch option {
            case MemeMakerPiclerOptions.libraryImagePicker:
                return wrapLibraryImagePicker()
                
            case MemeMakerPiclerOptions.tenor:
                if let childVC = childVC as? TenorVC {
                    childVC.pickerDelegate = self.pickerDelegate
                }
                break
                
            case MemeMakerPiclerOptions.clips:
                if let childVC = childVC as? ClipsVC {
                    childVC.pickerDelegate = self.pickerDelegate
                }
                break
                
            case MemeMakerPiclerOptions.giphy:
                if let childVC = childVC as? GiphyVC {
                    childVC.pickerDelegate = self.pickerDelegate
                }
                break
                
            case MemeMakerPiclerOptions.web:
                if let childVC = childVC as? WebVC {
                    childVC.pickerDelegate = self.pickerDelegate
                }
                break
                
            case MemeMakerPiclerOptions.camera:
                return wrapCamera()
                
            case MemeMakerPiclerOptions.files:
                return wrapFilePicker()
                
            default:
                break
                
            }
            //                if let childVC = childVC {
            //                    childVC.pickerDelegate = self.pickerDelegate
            //                }
            
            return childVC!
            
        }
        //        if let firstVC = viewControllersList.first {
        //            setViewControllers([firstVC], direction: .forward, animated: false , completion: nil)
        //        }
        if let scrollView = view.subviews.compactMap({$0 as? UIScrollView}).first {
            scrollView.isScrollEnabled = false
        }
    }
    
    func switchToViewController(at index: Int) {
        
        guard index >= 0 && index < viewControllersList.count else { return }
        let selectedVC = viewControllersList[index]
        
        switch MemeMakerPiclerOptions.allCases[index] {
            
        case .files:
            present(selectedVC, animated: true, completion: nil)
            break
            
        case .camera:
            present(selectedVC, animated: true, completion: nil)
            break
            
        default:
            prevSelectedIndex = index
            setViewControllers([selectedVC], direction: .forward, animated: false, completion: nil)
            break
        }
        
    }
    
    private func wrapLibraryImagePicker() -> UIViewController {
        let imagePicker = MemeImagePicker()
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        imagePicker.allowsEditing = false
        imagePicker.overrideUserInterfaceStyle = .dark
        imagePicker.view.tintColor = selectedYelloColor
        
        imagePicker.delegate = self
        
        return imagePicker
    }
    
    private func wrapFilePicker() -> UIViewController {
        
        let documentTypes = [
            kUTTypeImage as String,
            kUTTypeMovie as String,
            kUTTypeGIF as String
        ]
        
        let documentPicker = MemeFilePicker(documentTypes: documentTypes, in: .import)
        documentPicker.allowsMultipleSelection = false
        documentPicker.overrideUserInterfaceStyle = .dark
        documentPicker.view.tintColor = selectedYelloColor
        documentPicker.modalPresentationStyle = .fullScreen
        
        documentPicker.delegate = self
        
        return documentPicker
    }
    
    func wrapCamera() -> UIViewController {
        let cameraVC = UIImagePickerController()
        cameraVC.sourceType = .camera
        cameraVC.mediaTypes = ["public.image", "public.movie"]
        cameraVC.allowsEditing = false
        cameraVC.overrideUserInterfaceStyle = .dark
        cameraVC.view.tintColor = selectedYelloColor

        cameraVC.delegate = self
        
        return cameraVC
    }
    
}

extension MemeMakerRootPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if picker.sourceType == .photoLibrary {
            
            if let selectedImage = info[.originalImage] as? UIImage {
                pickerDelegate?.memeMakerMediaPickerController(didFinishPickingWithImage: selectedImage)
            } else if let selectedVideoURL = info[.mediaURL] as? URL {
                pickerDelegate?.memeMakerMediaPickerController(didFinishPickingWithGif: selectedVideoURL)
            }
            
            dismiss(animated: true)
        } else if picker.sourceType == .camera {
            
            if let selectedImage = info[.originalImage] as? UIImage {
                pickerDelegate?.memeMakerMediaPickerController(didFinishPickingWithImage: selectedImage)
            } else if let selectedVideoURL = info[.mediaURL] as? URL {
                pickerDelegate?.memeMakerMediaPickerController(didFinishPickingWithGif: selectedVideoURL)
            }
            
            picker.dismiss(animated: true)
            dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        if picker.sourceType == .camera {
            fileDelegate?.MemeMakerFilePickerControllerDelegate(selectItemAt: prevSelectedIndex)
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension MemeMakerRootPageViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else { return }
        
        let fileExtention = selectedFileURL.pathExtension.lowercased()
        
        switch fileExtention {
            
        case "jpg", "jpeg", "png":
            if let image = UIImage(contentsOfFile: selectedFileURL.path) {
                pickerDelegate?.memeMakerMediaPickerController(didFinishPickingWithImage: image)
            }
            break
            
        case "gif":
            pickerDelegate?.memeMakerMediaPickerController(didFinishPickingWithGif: selectedFileURL)
            break
            
        case "mov", "mp4":
            pickerDelegate?.memeMakerMediaPickerController(didFinishPickingWithVideo: selectedFileURL)
            break
            
        default:
            print("Unsupported file type: \(fileExtention)")
            break
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        //dismiss(animated: true, completion: nil)
        fileDelegate?.MemeMakerFilePickerControllerDelegate(selectItemAt: prevSelectedIndex)
    }
}

