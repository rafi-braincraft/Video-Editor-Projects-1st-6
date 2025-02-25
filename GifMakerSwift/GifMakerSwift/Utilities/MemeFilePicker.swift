//
//  MemeFilePicker.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 13/2/25.
//

import UIKit

class MemeFilePicker: UIDocumentPickerViewController {
    
//    weak var pickerDelegate: MemeMakerPickerControllerDelegate?
//    weak var fileDelegate: MemeMakerFilePickerControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        //overrideUserInterfaceStyle = .dark
    }
}

