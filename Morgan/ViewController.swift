//
//  ViewController.swift
//  Morgan
//
//  Created by Yagil Burowski on 3/24/15.
//  Copyright (c) 2015 CIS350FTW. All rights reserved.
//

import UIKit

import CoreLocation

var KEYBOARD_HEIGHT: CGFloat = 0
class ViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    var ansView : UIView = UIView()
    let BOTTOM_CONSTRAINT: CGFloat = 10.0
    var userLoc: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var manager: CLLocationManager = CLLocationManager()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var sendConstraint: NSLayoutConstraint!
    @IBOutlet var txtFieldConstraint: NSLayoutConstraint!
    var messages: [Message] = []
    
    /*
     * Sends a message from the user
     */
    @IBAction func sendMessage(sender: AnyObject) {
        if messageTextField.text != "" {
            var message:Message = Message(content: messageTextField.text, isMorgan: false)
            messages.append(message)
            updateTableView()
            Server.postToServer(message.content, lat: Double(userLoc.latitude), lon: Double(userLoc.longitude))
        }
        messageTextField.text = ""
    }
    
    /*
     * Morgan's response (random for now)
     */
    func morganAnswers () {
        let content = morganResponse
        var message:Message = Message(content: content, isMorgan: true)
        messages.append(message)
        updateTableView()

        
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            self.showAnswerButtons()
//        })

    }
    
    /*
     * Here we add delegates to TableView, and TextField, along with dynamic resizing of cells based on their content.
     * We also set the keyboard observers to capture all events with the keyboard popping up. 
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        messageTextField.delegate = self
        
        setUpLocation()
        
        let content1 = "Hello! I'm Morgan!"
        let content2 = "How can I help you?"
        let welcomeMsg: Message = Message(content: content1, isMorgan: true)
        let welcomeMsg2: Message = Message(content: content2, isMorgan: true)
        messages.append(welcomeMsg)
        messages.append(welcomeMsg2)
        
        
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "morganAnswers", name:"morganAnsweredNotification", object: nil)


        txtFieldConstraint.constant = BOTTOM_CONSTRAINT
        sendConstraint.constant = BOTTOM_CONSTRAINT
    }
    
   /*
    * Apple's standard
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    /*
     * Sections in the table. (We only need one)
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
   /*
    * One row for each message in the convo
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return messages.count
    }
    
   /*
    * Queue the cells
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier: String

        if messages[indexPath.row].isMorgan {
            cellIdentifier = "morganCell"
        } else {
            cellIdentifier = "userMessageCell"
        }

        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        // prevent appending layers on layers
        cell.contentView.viewWithTag(500)?.removeFromSuperview()
        var theLabel : UILabel = cell.viewWithTag(1) as UILabel
        theLabel.font = theLabel.font.fontWithSize(17)
        
        if cellIdentifier == "morganCell" {

            cell.contentView.addSubview(theLabel)

            theLabel.lineBreakMode = .ByWordWrapping
            theLabel.numberOfLines = 0
            theLabel.text = messages[indexPath.row].content
            
            theLabel.sizeToFit()
            let numCharsInLabel: CGFloat = CGFloat(countElements(theLabel.text!))
            let size = NSString(string: theLabel.text!).sizeWithAttributes([NSFontAttributeName: theLabel.font])
            let setTxtWidth = (numCharsInLabel < 26) ? size.width : size.width / (numCharsInLabel / 28.0)
            let rect = CGRectMake(theLabel.frame.origin.x, theLabel.frame.origin.y, setTxtWidth, theLabel.frame.height)
            

            let bubbleView: UIView = UIView(frame: rect)
            bubbleView.layer.borderColor = UIColor(red: 229 / 255.0, green: 229 / 255.0, blue: 234 / 255.0, alpha: 1).CGColor
            bubbleView.backgroundColor = UIColor(red: 229 / 255.0, green: 229 / 255.0, blue: 234 / 255.0, alpha: 1)
            theLabel.textColor = UIColor.blackColor()
            bubbleView.layer.borderWidth = 1
            bubbleView.layer.cornerRadius = 18
            bubbleView.layer.masksToBounds = true
            bubbleView.bounds = CGRectInset(bubbleView.frame, -10, -8)
            bubbleView.tag = 500
            cell.contentView.addSubview(bubbleView)
            cell.contentView.sendSubviewToBack(bubbleView)
        } else if cellIdentifier == "userMessageCell" {

            cell.contentView.addSubview(theLabel)
            
            theLabel.lineBreakMode = .ByWordWrapping
            theLabel.numberOfLines = 0
            theLabel.text = messages[indexPath.row].content
            
            theLabel.sizeToFit()
            let numCharsInLabel = CGFloat(countElements(theLabel.text!))
            if (numCharsInLabel < 26) {
                theLabel.textAlignment = .Right
            }
            
            let size = NSString(string: theLabel.text!).sizeWithAttributes([NSFontAttributeName: theLabel.font])
            
            let setTxtWidth = (numCharsInLabel < 26) ? size.width : size.width / (numCharsInLabel / 28.0)
            
            let widthOfScreen = UIScreen.mainScreen().applicationFrame.width
            let xCoord = widthOfScreen - setTxtWidth - 14
            
            let rect = CGRectMake(xCoord, theLabel.frame.origin.y, setTxtWidth, theLabel.frame.height)

            let bubbleView: UIView = UIView(frame: rect)
            bubbleView.layer.borderColor = UIColor.clearColor().CGColor
            bubbleView.backgroundColor = UIColor(red: 67 / 255.0, green: 174 / 255.0, blue: 247 / 255.0, alpha: 0.8)
            theLabel.textColor = UIColor.whiteColor()
            bubbleView.layer.borderWidth = 1
            bubbleView.layer.cornerRadius = 18
            bubbleView.layer.masksToBounds = true
            bubbleView.tag = 500
            bubbleView.bounds = CGRectInset(bubbleView.frame, -10, -8)
            cell.contentView.addSubview(bubbleView)
            cell.contentView.sendSubviewToBack(bubbleView)
        }
        return cell
    }
    
   /*
    * Properly reloads the messages in the conversation to move them accordingly.
    */
    func updateTableView() {

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            if self.tableView.contentSize.height > self.tableView.frame.size.height {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        })
    }
    
   /*
    * Resign textfield upon return
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        txtFieldConstraint.constant = BOTTOM_CONSTRAINT
        sendConstraint.constant = BOTTOM_CONSTRAINT
        return true
    }
    
    /*
     * Called when keyboard is about to be dismissed
     */
    func keyboardWillBeHidden(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                txtFieldConstraint.constant = BOTTOM_CONSTRAINT
                sendConstraint.constant = BOTTOM_CONSTRAINT
                
                // this isn't really needed here, they keyboard closes on its own but a little slower is better i think
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    /*
     * Called when keyboard is about to appear. Properly adjusts text fields and buttons, etc.
     */
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                KEYBOARD_HEIGHT = keyboardHeight
                if tableView.contentSize.height > keyboardHeight {
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                }
                txtFieldConstraint.constant = keyboardHeight + BOTTOM_CONSTRAINT
                sendConstraint.constant = keyboardHeight + BOTTOM_CONSTRAINT
                self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + keyboardHeight)
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    

    // MARK: location set up
    
    /*
     * sets up the location grabbing
     */
    func setUpLocation() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    /*
     * Update location
     */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var userLocation = locations[0] as CLLocation
        
        let lat = userLocation.coordinate.latitude
        let lon = userLocation.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.01
        let lonDelta: CLLocationDegrees = 0.01
        userLoc = CLLocationCoordinate2DMake(lat, lon)
        // stop updating after found to save battery
        manager.stopUpdatingLocation()
    }
    
    /*
     * Error with location service
     */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
//    /*
//     * Pop over custom answer choices
//     */
//    func showAnswerButtons() {
//        self.ansView = UIView(frame: CGRectMake(0, UIScreen.mainScreen().applicationFrame.height - KEYBOARD_HEIGHT, UIScreen.mainScreen().applicationFrame.width, KEYBOARD_HEIGHT + 20))
//        self.ansView.backgroundColor = UIColor(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0, alpha: 1)
//
//        self.view.addSubview(ansView)
//            self.messageTextField.resignFirstResponder()
//        generateAutoResponseButtons(["I'm down! Show me tickets.", "Not sure. Give me more info.", "Fuck you morgan. Show me something else!"])
//        
//    }
    
    func generateAutoResponseButtons(options : [String]) {
        var initialY : CGFloat = 40
        for option in options {
            let likeBtn = UIButton.buttonWithType(UIButtonType.System) as UIButton
            likeBtn.setTitle(option, forState: UIControlState.Normal)
            likeBtn.frame = CGRectMake(15, initialY, UIScreen.mainScreen().applicationFrame.width - 30, 50)
            likeBtn.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
            likeBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            likeBtn.titleLabel?.minimumScaleFactor = 0.2
            likeBtn.backgroundColor = UIColor.whiteColor()
            likeBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            likeBtn.layer.borderColor = UIColor.blackColor().CGColor
            likeBtn.layer.borderWidth = 2
            likeBtn.layer.cornerRadius = 5
            initialY += likeBtn.frame.size.height + 10
            likeBtn.addTarget(self, action: "sendMessageFromAutoRepsonseButton:", forControlEvents: .TouchUpInside)
            self.ansView.addSubview(likeBtn)
        }
    }
    
    func sendMessageFromAutoRepsonseButton(sender : UIButton) {
        let messageText = sender.titleLabel?.text
        var message:Message = Message(content: messageText!, isMorgan: false)
        messages.append(message)
        updateTableView()
        Server.postToServer(message.content, lat: Double(userLoc.latitude), lon: Double(userLoc.longitude))
        dismissAutoResponsePane()
    }
    
    func dismissAutoResponsePane() {
        self.ansView.removeFromSuperview()
        
    }
}
