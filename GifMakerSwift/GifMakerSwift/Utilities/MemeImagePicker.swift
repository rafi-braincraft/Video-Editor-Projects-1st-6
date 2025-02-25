//
//  MemeImagePicker.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 12/2/25.
//
import UIKit

class MemeImagePicker: UIImagePickerController {
    
    //weak var pickerDelegate: MemeMakerPickerControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}
