//
//  ViewController.swift
//  Pace
//
//  Created by Christian Ayscue on 3/21/15.
//  Copyright (c) 2015 christianayscue. All rights reserved.
//

import UIKit
import CoreLocation

var units: String!

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UIAlertViewDelegate {

    var running: Bool
    
    required init(coder aDecoder: NSCoder) {
        running = false
        manager = CLLocationManager()
        units = "Miles"
        super.init(coder: aDecoder)
    }
    
    @IBOutlet weak var setPaceLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var okButton: UIButton!
    
    @IBAction func OKButton(sender: AnyObject) {
        self.textField.resignFirstResponder()
    }
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startButtonPress(sender: AnyObject) {
        //set up gps
        if startButton.titleLabel?.text == "Ready" || startButton.titleLabel?.text == "Enable GPS"{
            //if we dont have authorization, ask to enable it
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways{
                manager.requestAlwaysAuthorization()
                startButton.setTitle("Enable GPS", forState: UIControlState.Normal)
            }else{
                startButton.setTitle("Loading GPS...", forState: UIControlState.Normal)
                startButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                //start updating
                manager.startUpdatingLocation()
            }
        }
        //start the run
        if startButton.titleLabel?.text == "Start"{
            running = true
        }
    }
    
    @IBAction func clear(sender: AnyObject) {
        if (running){
            var alert = UIAlertView(title: "Clear Run?", message: "Stop and clear this run?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == "Clear Run?" {
            if buttonIndex == 0 {
                alertView.dismissWithClickedButtonIndex(0, animated: true)
            }else{
                self.clearRun()
                alertView.dismissWithClickedButtonIndex(0, animated: true)
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if (textField.isFirstResponder()){
            textField.resignFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        imageView.image = UIImage(named: "Pace_Background.jpg")?.applyTintEffectWithColor(UIColor.whiteColor().colorWithAlphaComponent(0.7))
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
        //responds when textfield is shown or hidden
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeShown:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTextField", name: UITextFieldTextDidChangeNotification, object: textField)
        textField.tintColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //when we update
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if(locations[0] as CLLocation).coordinate.latitude != CLLocationDegrees(0){ //if received good coordinate
            if running{
                
            
            }else{ //enable start button
                if startButton.titleLabel?.text != "Start"{
                    startButton.setTitle("Start", forState: UIControlState.Normal)
                    startButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
                }
            }
        }
    }
    
    //clear all data
    func clearRun(){
    
    }
    
    //when keyboard shows, slide view up
    func keyboardWillBeShown(aNotification: NSNotification)
    {
        var info = aNotification.userInfo! as Dictionary<NSObject,AnyObject>
        var kbSize = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size
        okButton.alpha = 1
        //slides text input view with keyboard
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            var frame = self.view.frame
            frame.origin.y = -kbSize!.height
            self.view.frame = frame
            
        })
    }
    
    //when keyboard hides, slide view down
    func keyboardWillBeHidden(aNotification: NSNotification){
        //slides text input view with keyboard
        
        okButton.alpha = 0
        UIView.animateWithDuration(0.2, animations:{ () -> Void in
            var frame = self.view.frame
            frame.origin.y = 0
            self.view.frame = frame
        })
    }
    
    func updateTextField(){
        //fixes last digit removal bug
        if textField.text == ""{
            setPaceLabel.text = "00:00 min"
        }else if var paceInt = textField.text.toInt(){
            //sets the label in the order that the numbers are entered
            //paceInt%10 is the last number entered, paceInt/10%10 is the second to last entered, paceInt/100%10 is the third to last entered, and paceInt/1000&10 is the fourth to last entered
            if paceInt < 10000 && paceInt >= 1000{
                setPaceLabel.text = "\(paceInt/1000%10)\(paceInt/100%10):\(paceInt/10%10)\(paceInt%10) min"
            }else if paceInt < 1000 && paceInt >= 100{
                setPaceLabel.text = "\(paceInt/100%10)\(paceInt/10%10):\(paceInt%10)0 min"
            }else if paceInt < 100 && paceInt >= 10{
                setPaceLabel.text = "\(paceInt/10%10)\(paceInt%10):00 min"
            }else if paceInt < 10{
                setPaceLabel.text = "\(paceInt%10)0:00 min"
            }else if textField.text.toInt() >= 10000{
                //delete to keep number in resonable range
                textField.deleteBackward()
            }
        }
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        <#code#>
//    }
}

