//
//  MainViewController.swift
//  CollectionTabView
//
//  Created by Mohammad Noor on 19/1/25.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var openSubViewControllerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        view.window?.overrideUserInterfaceStyle = .dark
    }
    
    @IBAction func goToSubVC(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let subMainVC = storyboard.instantiateViewController(withIdentifier: "MemeMakerNavigationController") as? UINavigationController else { return }
        
        //subMainVC.modalTransitionStyle = .crossDissolve
        present(subMainVC, animated: true, completion: nil)
    
    }
    
}
