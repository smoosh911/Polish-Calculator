//
//  SettingsViewController.swift
//  Polish Calculator
//
//  Created by Michael Perry on 2/10/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Spring

class SettingsViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    // outlets
    @IBOutlet weak var viewProfileModal: SpringView!
    
    @IBOutlet weak var viewFacebookButtonView: UIView!
    @IBOutlet weak var cnstrntModalWidth: NSLayoutConstraint!
    @IBOutlet weak var lblProfileName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var swtchPsychedelic: UISwitch!
    
    // actions
    @IBAction func btnClose_Clicked(sender: AnyObject) {
        UIApplication.sharedApplication().sendAction("maximizeView:", to: nil, from: self, forEvent: nil)
        
        viewProfileModal.animation = "slideRight"
        viewProfileModal.animateFrom = false
        viewProfileModal.animateToNext({
            self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    
    @IBAction func swtchPsychedelic_ValChanged(sender: AnyObject) {
        
        if let switchBool = NSUserDefaults.standardUserDefaults().objectForKey("psychedelic") as? Bool {
            NSUserDefaults.standardUserDefaults().setBool(!switchBool, forKey: "psychedelic")
            NSNotificationCenter.defaultCenter().postNotificationName("stopOrStartTimers", object: nil)
        }
    }
    
    // variables
    
    let FBLoginManager = FBSDKLoginManager()

    // view life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let switchOn = NSUserDefaults.standardUserDefaults().objectForKey("psychedelic") as? Bool {
            swtchPsychedelic.setOn(switchOn, animated: true)
        }
        
        viewProfileModal.transform = CGAffineTransformMakeTranslation(-300, 0)
        
        let differenceBetweenFrameWidthAndModalWidth = self.view.frame.width - cnstrntModalWidth.constant
        
        if differenceBetweenFrameWidthAndModalWidth < 100 {
            let distanceToSubtractFronConstraint = 100 - differenceBetweenFrameWidthAndModalWidth
            cnstrntModalWidth.constant = cnstrntModalWidth.constant - distanceToSubtractFronConstraint
        }
        
        let accessToken = FBSDKAccessToken.currentAccessToken()
        if(accessToken != nil)
        {
            self.imgProfile.image = nil
        }
        
        returnUserData(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        viewProfileModal.animate()
        
        UIApplication.sharedApplication().sendAction("minimizeView:", to: nil, from: self, forEvent: nil)
        
        let facebookLoginButton = FBSDKLoginButton()
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["public_profile","email","user_friends"]
        self.viewFacebookButtonView.addSubview(facebookLoginButton)
        facebookLoginButton.center = CGPointMake(viewFacebookButtonView.bounds.size.width  / 2, viewFacebookButtonView.bounds.size.height / 2);
        
    }
    
    //mark: facebook
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        if error != nil {
            print(error.localizedDescription)

        } else if result.grantedPermissions != nil {
            print("login complete")
            print(result.grantedPermissions)
            FBLoginManager.logInWithPublishPermissions(["publish_actions"], fromViewController: self, handler: { (response, error) -> Void in
                if(error != nil){
                    print(error)
                } else {
                    if let facebookBool = NSUserDefaults.standardUserDefaults().objectForKey("postToFacebook") as? Bool {
                        print(facebookBool)
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "postToFacebook")
                        NSNotificationCenter.defaultCenter().postNotificationName("enableFacebookIcon", object: nil)
                    }
                }
            })
            returnUserData(true)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        //logout
        print("logout")
        lblProfileName.text = "Sign In"
        imgProfile.image = UIImage(named: "noProfileImg")
        if let facebookBool = NSUserDefaults.standardUserDefaults().objectForKey("postToFacebook") as? Bool {
            print(facebookBool)
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "postToFacebook")
            NSNotificationCenter.defaultCenter().postNotificationName("disableFacebookButton", object: nil)
        }
    }
    
    //The crossDisolvePicture is just so that when they sign it at first it transistions but not everytime the view slides out
    func returnUserData(crossDisolvePicture: Bool) {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, email, name, third_party_id, picture.type(large), friends"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: Couldn't get facebook info")
            }
            else
            {
                let userName : String = result.valueForKey("name") as! String
                let userEmail : String = result.valueForKey("email") as! String
                
                let userPicture: String = result.valueForKey("picture")!.valueForKey("data")!.valueForKey("url")! as! String
                let userImageURL = NSURL(string: userPicture)
                let task = NSURLSession.sharedSession().dataTaskWithURL(userImageURL!, completionHandler: { (data, response, error) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if let profilePic = UIImage(data: data!) {
                                if crossDisolvePicture {
                                    UIView.transitionWithView(self.imgProfile, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                                        self.imgProfile.image = profilePic
                                        }, completion: nil)
                                }
                                
                                self.imgProfile.image = profilePic
                                self.imgProfile.contentMode = UIViewContentMode.ScaleAspectFill
                                self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width / 2
                                self.imgProfile.clipsToBounds = true
                                self.lblProfileName.text = userName
                                self.lblEmail.text = userEmail
                            }
                        })
                    }
                })
                
                task.resume()
            }
        })
    }
}