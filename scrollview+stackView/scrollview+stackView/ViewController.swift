//
//  ViewController.swift
//  scrollview+stackView
//
//  Created by Mohammad Noor on 1/12/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var barTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var barLeadingConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var sliderStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func horizontalScrollItemClick(_ sender: UIButton) {
        
        barLeadingConstraints.isActive = false
        barTrailingConstraint.isActive = false

        barLeadingConstraints = sliderView.leadingAnchor.constraint(equalTo: sender.leadingAnchor, constant: 10)
        barTrailingConstraint = sliderView.trailingAnchor.constraint(equalTo: sender.trailingAnchor, constant: -10) 

        barLeadingConstraints.isActive = true
        barTrailingConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: {
            self.scrollButtonToCenter(button: sender)
            self.view.layoutIfNeeded()
        })
       
        
    }

    
    private func scrollButtonToCenter(button: UIButton) {
        guard let scrollView = button.superview?.superview as? UIScrollView else { return }
        
        let buttonCenter = button.frame.midX
        let scrollViewCenter = scrollView.frame.width / 2
        
        var newOffset = buttonCenter - scrollViewCenter
        
        newOffset = max(0, min(newOffset, scrollView.contentSize.width - scrollView.frame.width))
        
        UIView.animate(withDuration: 0.5) {
            scrollView.setContentOffset(CGPoint(x: newOffset, y: 0), animated: false)
        }
    }
    
}

