//
//  FacebookNotificationViewController.swift
//  Polish Calculator
//
//  Created by Michael Perry on 2/12/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import Spring

class FacebookNotificationViewController: UIViewController {
    
    // outlets
    @IBOutlet weak var viewNotificationsModal: SpringView!
    @IBOutlet weak var lblNotification: UILabel!
    
    // variables
    var facebookNotification: String!
    
    // view life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let transform = self.view.frame.height + 30
        viewNotificationsModal.transform = CGAffineTransformMakeTranslation(0, transform)
        self.lblNotification.text = facebookNotification
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.viewNotificationsModal.animation = "slideUp"
            self.viewNotificationsModal.animateFrom = false
            self.viewNotificationsModal.animateToNext({
                self.dismissViewControllerAnimated(false, completion: nil)
            })
            
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        viewNotificationsModal.animate()
        
    }
}
