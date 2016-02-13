//
//  CalculatorViewController.swift
//  Calculator Walkthrough
//
//  Created by Michael Perry on 9/12/15.
//  Copyright © 2015 Michael Perry. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class PolishCalculatorViewController: UIViewController {
    
    // Outlets
    //lblBrainDescription shows equation
    //lblAnswer shows computed property
    @IBOutlet weak var lblBrainDescription: UILabel!
    @IBOutlet weak var lblAnswer: UILabel!
    
    @IBOutlet weak var btnFacebook: UIBarButtonItem!
    @IBOutlet var viewMain: UIView!
    @IBOutlet var allButtons: [UIButton]!
    
    // Variables
    var brain = CalculatorBrain()
    var userIsTypingNumber: Bool = false
    var facebookNotification: String?
    
    private var timer: NSTimer?
    
    var ranColorNums: (color1: Float, color2: Float, color3: Float, alpha: Float, duration: Double)!
    var buttonColor: UIColor!
    var backgroundColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let facebookBool = NSUserDefaults.standardUserDefaults().objectForKey("postToFacebook") as? Bool {
            if facebookBool {
                enableFacebookIcon()
            }
        }
        //set userdefault change notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopOrStartTimers", name: "stopOrStartTimers", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enableFacebookIcon", name: "enableFacebookIcon", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "disableFacebookButton", name: "disableFacebookButton", object: nil)
        
        //start a timer for psychedelic colors
        if let switchBool = NSUserDefaults.standardUserDefaults().objectForKey("psychedelic") as? Bool {
            if switchBool == true {
                changeButtonsColors()
                    self.timer = NSTimer(timeInterval: 1.0, target: self, selector: "changeButtonsColors", userInfo: nil, repeats: true)
                    NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: "NSDefaultRunLoopMode")
            }
        }
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
        
    }
    
    func stopOrStartTimers() {
        if let switchBool = NSUserDefaults.standardUserDefaults().objectForKey("psychedelic") as? Bool {
            if switchBool == true {
                    self.timer = NSTimer(timeInterval: 1.0, target: self, selector: "changeButtonsColors", userInfo: nil, repeats: true)
                    NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: "NSDefaultRunLoopMode")
            } else {
                self.timer?.invalidate()
                self.timer = nil
                resetView()
            }
        }

    }
    
    func changeButtonsColors () {
        if let switchBool = NSUserDefaults.standardUserDefaults().objectForKey("psychedelic") as? Bool {
            if switchBool == true {
                for button in allButtons {
                    ranColorNums = ranBetweenNums(0.0, secondNum: 1.0, durationFirstNum: 0.0, durationSecondNum: 2.0)
                    buttonColor = UIColor(colorLiteralRed: ranColorNums.color1, green: ranColorNums.color2, blue: ranColorNums.color3, alpha: ranColorNums.alpha)
                    
                    ranColorNums = ranBetweenNums(0.0, secondNum: 1.0, durationFirstNum: 0.0, durationSecondNum: 2.0)
                    backgroundColor = UIColor(colorLiteralRed: ranColorNums.color1, green: ranColorNums.color2, blue: ranColorNums.color3, alpha: ranColorNums.alpha)
                    
                    // colors, alpha, and duration is randomly generated
                    UIView.animateWithDuration(ranColorNums.duration, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                        button.backgroundColor = self.buttonColor
                        button.setTitleColor(self.buttonColor.inverse(), forState: UIControlState.Normal)
                        self.viewMain.backgroundColor = self.backgroundColor
                        self.lblAnswer.textColor = self.backgroundColor.inverse()
                        self.lblBrainDescription.textColor = self.backgroundColor.inverse()
                        }, completion: { (Bool) -> Void in
                    
                    })
                }
            }
        }

    }
    
    func resetView () {
        let parent = self.view.superview
        self.view.removeFromSuperview()
        self.view = nil
        parent?.addSubview(self.view)
    }
    
    func enableFacebookIcon () {
        btnFacebook.enabled = true
    }
    
    func disableFacebookButton() {
        btnFacebook.enabled = false
    }
    
    // Actions
    
    //Adds digits to the displayValue when numbers are pressed
    @IBAction func btnAppendDigit(sender: AnyObject) {
        let digit = sender.currentTitle!
        
        dispatch_async(dispatch_get_main_queue()) {
        if self.userIsTypingNumber {
            if self.lblAnswer.text == "0" {
                self.lblAnswer.text = ""
                self.lblAnswer.text = self.lblAnswer.text! + digit!
            } else {
                self.lblAnswer.text = self.lblAnswer.text! + digit!
            }
            
        } else {
            self.lblAnswer.text = digit
            self.userIsTypingNumber = true
        }
        }
    }
    
    //Clears the stack and resets display values
    @IBAction func btnClear(sender: AnyObject) {
        if lblAnswer.text! != "0" {
            brain.clear()
            lblAnswer.text = "0"
        }
        if displayBrain != " " {
            displayBrain = " "
        }
    }
    
    //Backspaces one at a time until 0
    @IBAction func btnBackSpace(sender: AnyObject) {
        if lblAnswer.text!.characters.count > 1 {
            lblAnswer.text = lblAnswer.text!.substringToIndex((lblAnswer.text?.endIndex.predecessor())!)
        } else if (lblAnswer.text?.characters.count)! == 1 {
            lblAnswer.text = "0"
        }
    }
    
    //handles when and how to add a period
    @IBAction func btnAppendPeriod(sender: AnyObject) {
        let period = sender.currentTitle!
        
        if (lblAnswer.text?.containsString(".") == true){
            if userIsTypingNumber == false {
                lblAnswer.text = "0\(period!)"
                userIsTypingNumber = true
            }
        } else {
            if userIsTypingNumber {
                lblAnswer.text = lblAnswer.text! + period!
            } else {
                lblAnswer.text = "0\(period!)"
                userIsTypingNumber = true
            }
        }
    }
    
    //sends operand or constant to the stack and returns the displayBrain value
    @IBAction func btnEnter() {
        userIsTypingNumber = false
        
        //check for pie value, if there is one then add its string to the que, not its double value.
        //else just push operand onto stack
        if String(displayBrain).containsString("π=") && String(displayValue).containsString("3.14") {
            if let operation = displayValue {
                if let result = brain.performOperation(String(operation)) {
                    displayValue = result
                } else {
                    displayValue = 0
                }
            }
        } else {
            if let result = brain.pushOperand(displayValue!) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
        
        if let brainResult: String = brain.description {
            displayBrain = "\(brainResult)="
        } else {
            displayBrain = " "
        }
    }
    
    //performs operation when operation button is pressed
    @IBAction func btnOperate(sender: AnyObject) {
        if userIsTypingNumber {
            btnEnter()
        }
        
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation!) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
        if let brainResult: String = brain.description {
            displayBrain = "\(brainResult)="
        } else {
            displayBrain = " "
        }
    }
    
    @IBAction func btnCompose_Clicked(sender: AnyObject) {
        postToFacebook()
    }
    
    // Computed properties
    
    var displayValue: Double? {
        get {
            if let numberFromLblAnswer: Double = NSNumberFormatter().numberFromString(lblAnswer.text!)?.doubleValue {
                return numberFromLblAnswer
            } else {
                return 0
            }
        }
        set {
            if let nwVal = newValue {
                lblAnswer.text = "\(nwVal)"
            } else {
                lblAnswer.text = nil
            }
        }
    }
    
    var displayBrain: String {
        get {
            return lblBrainDescription.text!
        }
        set {
            lblBrainDescription.text = "\(newValue)"
        }
    }
    
    // get random numbers
    
    func ranBetweenNums(firstNum: CGFloat, secondNum: CGFloat, durationFirstNum: CGFloat, durationSecondNum: CGFloat) -> (color1: Float, color2: Float, color3: Float, alpha: Float, duration: Double) {
        
        let color1 = Float(CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum))
        let color2 = Float(CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum))
        let color3 = Float(CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum))
        let alpha = Float(CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum))
        let duration = Double(CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(durationFirstNum - durationSecondNum) + min(durationFirstNum, durationSecondNum))
        
        return (color1, color2, color3, alpha, duration)
    }
    
    // post to facebook
    
    func postToFacebook() {
        let facebookMessage = "Thanks to a genius app developer named Mike Perry, I was able to do this amazing calculation on his polish calculator! \n\n \(lblBrainDescription.text!) \n \(lblAnswer.text!)"
        let params = ["message": facebookMessage]
        
        let request : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/feed", parameters: params, HTTPMethod: "POST")
        request.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: Couldn't POST to facebook")
                self.facebookNotification = "Facebook Post Failed :("
                self.performSegueWithIdentifier("showNotification", sender: self)
            }
            else
            {
                print(result)
                self.facebookNotification = "Facebook Post Successfull!"
                self.performSegueWithIdentifier("showNotification", sender: self)
            }
        })
    }
    
    //segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showNotification" {
            if let notificationVC = segue.destinationViewController as? FacebookNotificationViewController {
                notificationVC.facebookNotification = facebookNotification
            }
        }
    }

}
