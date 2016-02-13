//
//  AppDelegate.swift
//  Calculator Walkthrough
//
//  Created by Michael Perry on 9/12/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if NSUserDefaults.standardUserDefaults().objectForKey("psychedelic") == nil {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "psychedelic")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey("postToFacebook") == nil {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "postToFacebook")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

}

