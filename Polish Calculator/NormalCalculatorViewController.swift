//
//  NormalCalculatorViewController.swift
//  Polish Calculator
//
//  Created by Michael Perry on 2/10/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import UIKit

class NormalCalculatorViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let polishVC: PolishCalculatorViewController = storyBoard.instantiateViewControllerWithIdentifier("Polish") as! PolishCalculatorViewController
        
        self.addChildViewController(polishVC)
        self.view.addSubview(polishVC.view)
    }
}