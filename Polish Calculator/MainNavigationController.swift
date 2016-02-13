//
//  MainNavigationViewController.swift
//  Fond Memories
//
//  Created by Michael Perry on 1/16/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import UIKit
import Spring

class MainNavigationController: UINavigationController {
    
    // mark: view animation
    
    func minimizeView(sender: AnyObject) {
        SpringAnimation.spring(0.7, animations: {
            self.view.transform = CGAffineTransformMakeScale(0.935, 0.935)
        })
    }
    
    func maximizeView(sender: AnyObject) {
        SpringAnimation.spring(0.7, animations: {
            self.view.transform = CGAffineTransformMakeScale(1, 1)
        })
    }
}