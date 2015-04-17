//
//  ViewController.swift
//  Morgan
//
//  Created by Yagil Burowski on 3/24/15.
//  Copyright (c) 2015 CIS350FTW. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import Foundation

/*
    James needs to use the Flask funtionality called "jsonify":
    cmd + f "jsonify" here (2nd result) http://flask.pocoo.org/docs/0.10/api/
    that will ensure we get a valid JSON response and it's supposed to work out-of-the-box
    with what we have built.
    ***IMPORTANT*** make sure he gives the tickets purchase link as "buyLink" attribute in the JSON
    other than that 
    we're chilling
    DONT FORGET TO CHECK FOR NULLPOINTER  EXCEPTION FOR THE INDEX !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*/

var KEYBOARD_HEIGHT: CGFloat = 0
class ViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var currentSongUrl = ""
    
    var buyLink : String = ""
    
    var player = AVPlayer()
    var typingLabel : UILabel = UILabel()
    var latestQuery : String = ""
    var gIndex : Int = 0
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
    * Here we add delegates to TableView, and TextField, along with dynamic resizing of cells based on their content.
    * We also set the keyboard observers to capture all events with the keyboard popping up.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        createMorganTitleAndSubtitle()
        self.tableView.delegate = self
        messageTextField.delegate = self
        
        setUpLocation()
        let content1 = "Hello! I'm Morgan! Tell me things like: 'show me concerts in New York' or 'concerts near me' "
        let welcomeMsg: Message = Message(content: content1, isMorgan: true)
        messages.append(welcomeMsg)
        
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "morganAnswers", name:"morganAnsweredNotification", object: nil)
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: "makePlayActive", name:"previewURLNotification", object: nil)
        txtFieldConstraint.constant = BOTTOM_CONSTRAINT
        sendConstraint.constant = BOTTOM_CONSTRAINT
    }
    
    /*
     * Apple's view call
     */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        verifyLocationServicesOn()
        
    }

    /*
     * Add a title/subtitle for Morgan and "typing..."
     */
    func createMorganTitleAndSubtitle() {
        var titleRect : UIView = UIView(frame: CGRectMake(0, 0, 120, 36))
        var morganLabel : UILabel = UILabel(frame: CGRectMake(0, 0, 120, 30))
        morganLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 19.0)
        morganLabel.text = "Morgan"
        morganLabel.textAlignment = .Center
        
        typingLabel = UILabel(frame: CGRectMake(0, 22, 120, 20))
        typingLabel.text = "Morgan is typing..."
        typingLabel.font = UIFont(name: "HelveticaNeue", size: 9.0)
        typingLabel.textAlignment = .Center

        titleRect.addSubview(morganLabel)
        titleRect.addSubview(typingLabel)
        self.navigationItem.titleView = titleRect
        removeMorganIsTyping()
    }

    /*
     * Sends a message from the user
     */
    @IBAction func sendMessage(sender: AnyObject) {
        if messageTextField.text != "" {
            var message:Message = Message(content: messageTextField.text, isMorgan: false)
            messages.append(message)
            updateTableView()
            showMorganIsTyping()
            
            Server.postToServer(message.content, lat: Double(userLoc.latitude), lon: Double(userLoc.longitude), index: 0)
            latestQuery = message.content
        }
        messageTextField.text = ""
    }
    
    /*
     * Morgan's response (random for now)
     */
    func morganAnswers () {
        var content: String = ""
        var error: NSError?
        var date: String = ""
        var artist: String = ""
        var venue: String = ""
        
//        let jsonData: NSData = morganResponse.stringByReplacingOccurrencesOfString("'", withString: "\"", options: .LiteralSearch, range: nil).dataUsingEncoding(NSUTF8StringEncoding)!
        let jsonData: NSData = morganResponse.dataUsingEncoding(NSUTF8StringEncoding)!
//        let jsonData: NSData = "{\"artist\": \"Bobby\", \"date\":\"7\", \"venue\":\"La Factoria\", \"preview\":\"http://a1148.phobos.apple.com/us/r1000/044/Music4/v4/a6/b5/cd/a6b5cd6b-3e55-3130-efa1-b8bd309eeca8/mzaf_7972923366726760857.plus.aac.p.m4a\"}".dataUsingEncoding(NSUTF8StringEncoding)!
        
        var err: NSError?
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
                
            } else {
                date = jsonResult["date"] as! String
                artist = jsonResult["artist"] as! String
                venue = jsonResult["venue"] as! String
                previewURL = jsonResult["preview"] as! String
                buyLink = jsonResult["ticketLink"] != nil ? jsonResult["ticketLink"] as! String : "http://www.ticketmaster.com/?id=234234234"
                content = "\(artist) is playing at \(venue) on \(date). Tap one of the following buttons for more info, or simply type a new question"
                println(content)
                var message:Message = Message(content: content, isMorgan: true)
                messages.append(message)
                updateTableView()
            }
            
        } else {
            println("json results didnt work")
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.removeMorganIsTyping()
        })
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.showAnswerButtons()
        })

    }
    
    /*
     * remove play button when user starts querying again
     */
    func removeBarButton() {
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = nil
        player.pause()
    }
    
    /*
     * Fires from a response
     */
    func makePlayActive() {
        let button = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Play, target: self, action: "tapPlay:")
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = button
    }
    
    /*
     * Play itunes preview
     */
    func tapPlay(sender: AnyObject) {
        currentSongUrl = previewURL
        
        // if player exists, resume instead of play
        
        let pItem = AVPlayerItem(URL: NSURL(string: currentSongUrl))
        player = AVPlayer(playerItem: pItem)
        player.rate = 1.0
        
        player.play()

        //change to pause
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause, target: self, action: "pauseMusic")
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem? = button
    }
    
    /*
     * Pause player
     */
    func pauseMusic() {
        player.pause()
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play, target: self, action: "tapPlay:")
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem? = button
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

        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        // prevent appending layers on layers
        cell.contentView.viewWithTag(500)?.removeFromSuperview()
        var theLabel : UILabel = cell.viewWithTag(1) as! UILabel
        theLabel.font = theLabel.font.fontWithSize(17)
        
        if cellIdentifier == "morganCell" {

            cell.contentView.addSubview(theLabel)

            theLabel.lineBreakMode = .ByWordWrapping
            theLabel.numberOfLines = 0
            theLabel.text = messages[indexPath.row].content
            
            theLabel.sizeToFit()
            let numCharsInLabel: CGFloat = CGFloat(count(theLabel.text!))
            let size = NSString(string: theLabel.text!).sizeWithAttributes([NSFontAttributeName: theLabel.font])
            let setTxtWidth = (numCharsInLabel < 30) ? size.width : size.width / (numCharsInLabel / 26.0)
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
            theLabel.textAlignment = .Left
            theLabel.sizeToFit()
            let numCharsInLabel = CGFloat(count(theLabel.text!))
            if (numCharsInLabel < 26) {
                theLabel.textAlignment = .Right
            }
            
            let size = NSString(string: theLabel.text!).sizeWithAttributes([NSFontAttributeName: theLabel.font])
            
            let setTxtWidth = (numCharsInLabel < 30) ? size.width : size.width / (numCharsInLabel / 26.0)
            
            let widthOfScreen = UIScreen.mainScreen().applicationFrame.width
            let xCoord = widthOfScreen - setTxtWidth - 20
            
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
    
    // MARK: keyboard code
    
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
        removeBarButton()
        
    }
    

    // MARK: location set up
    
    /*
     * sets up the location grabbing
     */
    func setUpLocation() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    /*
    * verifies location services authorization status and shows appropriate message
    */
    func verifyLocationServicesOn() {
        switch CLLocationManager.authorizationStatus() {
        case /*.Authorized,*/ .AuthorizedWhenInUse:
            println("location is authorized we're chilling")
            return
        case .NotDetermined:
            manager.requestAlwaysAuthorization()
            break;
        case .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "To let Morgan do her magic, please open this app's settings and set location access to 'While Using the App'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        default:
            break;
        }
    }
    /*
     * Update location
     */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var userLocation = locations[0] as!CLLocation
        
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
    
    /*
     * Pop over custom answer choices
     */
    func showAnswerButtons() {
        self.ansView = UIView(frame: CGRectMake(0, UIScreen.mainScreen().applicationFrame.height - KEYBOARD_HEIGHT, UIScreen.mainScreen().applicationFrame.width, KEYBOARD_HEIGHT + 20))
        self.ansView.backgroundColor = UIColor(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0, alpha: 1)
        self.messageTextField.resignFirstResponder()
        let transition = UIViewAnimationOptions.TransitionCrossDissolve
        UIView.transitionWithView(self.view, duration: 0.8, options: transition, animations: {
                                  self.view.addSubview(self.ansView)}, completion: nil)
        
        
        generateAutoResponseButtons(["I'm down! Show me tickets.", "Not sure. Give me more info.", "Fuck you morgan. Show me something else!"])
        
        generateRemoveSubviewButton()
    }
    
    
    
    // MARK: auto response code
    
    func generateRemoveSubviewButton() {
        let delete = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        delete.frame = CGRectMake(15, 10, 25, 25)
        delete.setTitle("X", forState: UIControlState.Normal)
        delete.layer.cornerRadius = 0.5 * delete.bounds.size.width
        delete.layer.borderWidth = 2
        delete.layer.borderColor = UIColor.blackColor().CGColor
        delete.addTarget(self, action: "dismissAutoResponsePane", forControlEvents: .TouchUpInside)
        delete.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        delete.titleLabel?.adjustsFontSizeToFitWidth = true
        delete.titleLabel?.minimumScaleFactor = 0.2
        delete.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        ansView.addSubview(delete)
    }
    
    /*
     * Auto response button generation
     */
    func generateAutoResponseButtons(options : [String]) {
        var initialY : CGFloat = 40
        var i : Int = 900
        for option in options {
            let button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            button.setTitle(option, forState: UIControlState.Normal)
            button.frame = CGRectMake(15, initialY, UIScreen.mainScreen().applicationFrame.width - 30, 50)
            button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.2
            button.backgroundColor = UIColor.whiteColor()
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 2
            button.layer.cornerRadius = 5
            button.tag = i
            i++
            initialY += button.frame.size.height + 10
            self.ansView.addSubview(button)
        }
        let button1: UIButton = self.view.viewWithTag(900) as! UIButton
        let button2: UIButton = self.view.viewWithTag(901) as! UIButton
        let button3: UIButton = self.view.viewWithTag(902) as! UIButton
        button1.addTarget(self, action: "showTicketsLink", forControlEvents: .TouchUpInside)
        button2.addTarget(self, action: "showPreviewSong", forControlEvents: .TouchUpInside)
        button3.addTarget(self, action: "showNextResult", forControlEvents: .TouchUpInside)
        
    }
    
    /* 
     * Recreates a message from the auto button selection
     */
    func sendMorganMessageFromAutoRepsonseButton(message : String) {
        let messageText = message
        var message:Message = Message(content: messageText, isMorgan: true)
        messages.append(message)
        updateTableView()
//        Server.postToServer(message.content, lat: Double(userLoc.latitude), lon: Double(userLoc.longitude))
        dismissAutoResponsePane()
    }
    
    /*
     * Dismisses auto-response
     */
    func dismissAutoResponsePane() {
        let transition = UIViewAnimationOptions.TransitionCrossDissolve
        UIView.transitionWithView(self.view, duration: 0.8, options: transition, animations: {
            self.ansView.removeFromSuperview()}, completion: nil)
    }
    
    /*
     * Bring up tix link
     */
    func showTicketsLink() {
        let button = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Action, target: self, action: "openPurchaseUrl")
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = button
        

        sendMorganMessageFromAutoRepsonseButton("Tap the action button on the top right to purchase tickets!")
        
    }
    
    func openPurchaseUrl() {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        let buyAction = UIAlertAction(title: "Open in Safari", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: self.buyLink)!)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Cancelled")
        })
        
        
        optionMenu.addAction(buyAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func showPreviewSong() {
        makePlayActive()
        sendMorganMessageFromAutoRepsonseButton("Here! Tap the play button in the top right corner to hear some tunes by this artist")
    }
    
    func showNextResult() {
        gIndex++
        Server.postToServer(latestQuery, lat: Double(userLoc.latitude), lon: Double(userLoc.longitude), index:gIndex)
        sendMorganMessageFromAutoRepsonseButton("np, coming up")
    }
    
    func showMorganIsTyping() {
        typingLabel.hidden = false
    }
    
    func removeMorganIsTyping() {
        typingLabel.hidden = true
    }
}
