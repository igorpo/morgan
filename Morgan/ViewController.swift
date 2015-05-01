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
import MapKit

var KEYBOARD_HEIGHT: CGFloat = 0
class ViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var currentSongUrl = ""
    
    @IBOutlet var showPaneAtWill: UIBarButtonItem!
    var buyLink : String = ""
    var shouldScroll : Bool = false
    var player = AVPlayer()
    var typingLabel : UILabel = UILabel()
    var latestQuery : String = ""
    var artist : String = ""
    var artist_pic : String = ""
    var gIndex : Int = 0
    var ansView : UIView = UIView()
    let BOTTOM_CONSTRAINT: CGFloat = 10.0
    var userLoc: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var manager: CLLocationManager = CLLocationManager()
    var venueLon : Double = 0
    var venueLat : Double = 0
    
    
    
    
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
        showPaneAtWill.enabled = false
        
        setUpLocation()
        let content1 = "Hello! I'm Morgan! Tell me things like: 'show me concerts in New York' or 'concerts near me'"
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
     * Show auto response pane in case closed
     */
    @IBAction func bringupButtons(sender: AnyObject) {
        showAnswerButtons()
    }
    
    /*
     * Add a title/subtitle for Morgan and "typing..."
     */
    func createMorganTitleAndSubtitle() {
        var titleRect : UIView = UIView(frame: CGRectMake(0, 0, 120, 36))
        var morganLabel : UILabel = UILabel(frame: CGRectMake(0, 0, 120, 30))
        morganLabel.font = UIFont(name: "Avenir-Heavy", size: 16.0)
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
            self.messageTextField.resignFirstResponder()
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
        var success : Bool = false
        let jsonData: NSData = morganResponse.dataUsingEncoding(NSUTF8StringEncoding)!
        
        var err: NSError?
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error: \(err!.localizedDescription)")
                
            } else {
                var message:Message
                var anteMessage : Message
                if (jsonResult["success"]?.boolValue != true) {
                    // something went wrong
                    success = false
                    let errMsg : String = jsonResult["message"] as! String
//                    anteMessage = Message(content: "Oops, something went wrong.", isMorgan: true)
                    message = Message(content: errMsg, isMorgan: true)
                    messages.append(message)
                    updateTableView()

                } else {
                    success = true
                    self.shouldScroll = true // for showing auto response buttons
                    date = jsonResult["date"] as! String
                    self.artist = jsonResult["artist"] as! String
                    self.artist_pic = jsonResult["artist_picture"] as! String
                    
                    //                self.venueLon = (jsonResult["venue_lng"] as? NSString)!.doubleValue
                    self.venueLon = jsonResult["venue_lng"]!.doubleValue
                    self.venueLat = jsonResult["venue_lat"]!.doubleValue
                    //                self.venueLat = (jsonResult["venue_lat"] as? NSString)!.doubleValue
                    venue = jsonResult["venue"] as! String
                    previewURL = jsonResult["preview"] as! String
                    buyLink = jsonResult["buyLink"] as! String != "None" ? jsonResult["buyLink"] as! String : "http://www.ticketmaster.com/"
                    
                    content = "\(self.artist) is playing at \(venue) on \(date). You can tap one of the following buttons for more info, or simply ask Morgan something else!"
                    println(content)
                    message = Message(content: content, isMorgan: true)
                    anteMessage = Responses.returnShowResponseMessage()
                    morganAnswersWithAnteMessage(anteMessage, message: message)
//                    self.tableView.frame.origin.y -= 150

                }
                

            }
            
        } else {
            println("json results didnt work")
            
            // random SORRY messages for bad queries
            
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.showPaneAtWill.enabled = true
            
        })
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.removeMorganIsTyping()
        })
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if success {
                self.showAnswerButtons()
            }

        })

    }
    
    func morganAnswersWithAnteMessage(anteMessage : Message, message: Message) {
        // send first message, delay, second message
        messages.append(anteMessage)
        updateTableView()
        // delay here:
        messages.append(message)
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
//        let button = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Play, target: self, action: "tapPlay:")
//        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = button
        println("play is now active")
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
//        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause, target: self, action: "pauseMusic")
//        self.navigationController?.navigationBar.topItem?.rightBarButtonItem? = button
        
        let playButton : UIButton = sender as! UIButton
        playButton.setImage(UIImage(named: "pause_btn_white"), forState: .Normal)
        playButton.addTarget(self, action: "pauseMusic:", forControlEvents: .TouchUpInside)
        
    }
    
    /*
     * Pause player
     */
    func pauseMusic(sender: AnyObject) {
        player.pause()
//        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play, target: self, action: "tapPlay:")
//        self.navigationController?.navigationBar.topItem?.rightBarButtonItem? = button
        let playButton : UIButton = sender as! UIButton
        playButton.setImage(UIImage(named: "play_btn_white"), forState: .Normal)
        playButton.addTarget(self, action: "tapPlay:", forControlEvents: .TouchUpInside)
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
        var currentMessage : Message = messages[indexPath.row]
        if messages[indexPath.row].isMorgan {
            cellIdentifier = "morganCell"
            if messages[indexPath.row].type == Message.MessageType.Preview {
                cellIdentifier = "previewCell"
            } else if messages[indexPath.row].type == Message.MessageType.Purchase {
                cellIdentifier = "purchaseCell"
            }
        } else {
            cellIdentifier = "userMessageCell"
        }

        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        
        cell.backgroundColor = UIColor.clearColor()
        
        if cellIdentifier == "morganCell" {
            // prevent appending layers on layers
            cell.contentView.viewWithTag(500)?.removeFromSuperview()
            var theLabel : UILabel = cell.viewWithTag(1) as! UILabel
            theLabel.font = theLabel.font.fontWithSize(14)
            
            cell.contentView.addSubview(theLabel)

            theLabel.lineBreakMode = .ByWordWrapping
            theLabel.numberOfLines = 0
            theLabel.text = messages[indexPath.row].content
            theLabel.sizeToFit()
            var labelTextCount : Int = theLabel.text!.lengthOfBytesUsingEncoding(NSUTF16StringEncoding) / 2
            let numCharsInLabel: CGFloat = CGFloat(labelTextCount)
            let size = NSString(string: theLabel.text!).sizeWithAttributes([NSFontAttributeName: theLabel.font])
            let setTxtWidth = (numCharsInLabel < 28) ? size.width : size.width / (numCharsInLabel / 29.0)
            let rect = CGRectMake(theLabel.frame.origin.x, theLabel.frame.origin.y, setTxtWidth, theLabel.frame.height)
            

            let bubbleView: UIView = UIView(frame: rect)
            bubbleView.backgroundColor = UIColor.whiteColor()
            theLabel.textColor = UIColor.blackColor()
            
            bubbleView.layer.cornerRadius = 10.0
            bubbleView.layer.borderColor = UIColor.grayColor().CGColor
            bubbleView.layer.borderWidth = 0.2
            bubbleView.clipsToBounds = true
            
            bubbleView.layer.shadowOffset = CGSize(width: 0, height: 0)
            bubbleView.layer.shadowOpacity = 0.7
            bubbleView.layer.shadowRadius = 2
            
            
            bubbleView.layer.masksToBounds = true
            bubbleView.bounds = CGRectInset(bubbleView.frame, -10, -8)
            bubbleView.tag = 500
            cell.contentView.addSubview(bubbleView)
            cell.contentView.sendSubviewToBack(bubbleView)
        } else if cellIdentifier == "userMessageCell" {
            // prevent appending layers on layers
            cell.contentView.viewWithTag(500)?.removeFromSuperview()
            var theLabel : UILabel = cell.viewWithTag(1) as! UILabel
            theLabel.font = theLabel.font.fontWithSize(14)
            cell.contentView.addSubview(theLabel)
            
            theLabel.lineBreakMode = .ByWordWrapping
            theLabel.numberOfLines = 0
            theLabel.text = messages[indexPath.row].content
            theLabel.textAlignment = .Left
            theLabel.sizeToFit()
            var labelTextCount : Int = theLabel.text!.lengthOfBytesUsingEncoding(NSUTF16StringEncoding) / 2
            let numCharsInLabel = CGFloat(labelTextCount)
            if (numCharsInLabel < 26) {
                theLabel.textAlignment = .Right
            }
            
            let size = NSString(string: theLabel.text!).sizeWithAttributes([NSFontAttributeName: theLabel.font])
            
            let setTxtWidth = (numCharsInLabel < 30) ? size.width : size.width / (numCharsInLabel / 29.0)
            
            let widthOfScreen = UIScreen.mainScreen().applicationFrame.width
            let xCoord = widthOfScreen - setTxtWidth - 20
            
            let rect = CGRectMake(xCoord, theLabel.frame.origin.y, setTxtWidth, theLabel.frame.height)

            let bubbleView: UIView = UIView(frame: rect)
            bubbleView.backgroundColor = UIColor(red: 67 / 255.0, green: 174 / 255.0, blue: 247 / 255.0, alpha: 0.8)
            theLabel.textColor = UIColor.whiteColor()
            
            bubbleView.layer.cornerRadius = 10.0
            bubbleView.layer.borderColor = UIColor.grayColor().CGColor
            bubbleView.layer.borderWidth = 0.2
            bubbleView.clipsToBounds = true
            
            bubbleView.layer.shadowOffset = CGSize(width: 0, height: 0)
            bubbleView.layer.shadowOpacity = 0.7
            bubbleView.layer.shadowRadius = 2
            
            bubbleView.layer.masksToBounds = true
            bubbleView.tag = 500
            bubbleView.bounds = CGRectInset(bubbleView.frame, -10, -8)
            cell.contentView.addSubview(bubbleView)
            cell.contentView.sendSubviewToBack(bubbleView)
        } else if cellIdentifier == "previewCell" {
            let imgRect = CGRectMake(11, 8, 177, 107)
            let box : UIView = (cell.viewWithTag(800) as UIView?)!
            let play_button: UIButton = cell.viewWithTag(111) as! UIButton
            play_button.addTarget(self, action: "tapPlay:", forControlEvents: .TouchUpInside)
            
            box.layer.cornerRadius = 10.0
            box.layer.borderColor = UIColor.grayColor().CGColor
            box.layer.borderWidth = 0.5
            box.clipsToBounds = true
            
            box.layer.shadowOffset = CGSize(width: 6, height: 6)
            box.layer.shadowOpacity = 0.7
            box.layer.shadowRadius = 2
            
            let artistLabel : UILabel = cell.viewWithTag(92) as! UILabel
            artistLabel.text = currentMessage.artist
            
//            self.artist_pic
            let url = NSURL(string: currentMessage.previewImgUrl)
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check

            
            let imgView: UIImageView = cell.viewWithTag(90) as! UIImageView
            imgView.image = UIImage(data: data!)
        } else if cellIdentifier == "purchaseCell" {
            println(currentMessage.lat)
            
            var venueMap : MKMapView = cell.viewWithTag(223) as! MKMapView
            let location : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: currentMessage.lat, longitude: currentMessage.lon)
            
            var information = MKPointAnnotation()
            information.coordinate = location
            
            // set zoom
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.003, 0.003)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            venueMap.addAnnotation(information)
            venueMap.setRegion(region, animated: true)
            let box : UIView = (cell.viewWithTag(800) as UIView?)!
            box.layer.cornerRadius = 10.0
            box.layer.borderColor = UIColor.grayColor().CGColor
            box.layer.borderWidth = 0.5
            box.clipsToBounds = true
            
            box.layer.shadowOffset = CGSize(width: 6, height: 6)
            box.layer.shadowOpacity = 0.7
            box.layer.shadowRadius = 2
            
            let purchaseBtn : UIPurchaseButton = cell.viewWithTag(222) as! UIPurchaseButton
            purchaseBtn.buyLink = currentMessage.buyLink
            purchaseBtn.addTarget(self, action: "openPurchaseUrl:", forControlEvents: .TouchUpInside)
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
//                UIView.animateWithDuration(2, animations: { () -> Void in
//                    self.view.layoutIfNeeded()
//                })
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
        // bring this back
//        self.messageTextField.hidden = true
        self.messageTextField.resignFirstResponder()
        let transition = UIViewAnimationOptions.TransitionCrossDissolve
        UIView.transitionWithView(self.view, duration: 0.8, options: transition, animations: {
                                  self.view.addSubview(self.ansView)}, completion: nil)
        generateAutoResponseButtons(["Show me tickets!", "Show Preview!", "Other result please!"])
        
        generateRemoveSubviewButton()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.frame.origin.y -= (KEYBOARD_HEIGHT - 100)
        })
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
        delete.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 14)
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
            let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            button.setTitle(option, forState: UIControlState.Normal)
            button.frame = CGRectMake(15, initialY, UIScreen.mainScreen().applicationFrame.width - 30, 50)
            button.titleLabel?.font = UIFont(name: "Avenir-Heavy ", size: 14)
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
    func sendMorganMessageFromAutoRepsonseButton(message : String, type: Message.MessageType) {
        let messageText = message
        var message : Message
        var anteMessage : Message
        if type == Message.MessageType.Purchase {
            message = Message(content: messageText, isMorgan: true, type: type, lon: self.venueLon, lat: self.venueLat, buyLink: self.buyLink)
            anteMessage = Responses.returnTicketResponseMessage()

        } else {
            message = Message(content: messageText, isMorgan: true, type: type, artist: self.artist, previewImgUrl: self.artist_pic)
            anteMessage = Responses.returnPreviewResponseMessage()
        }
        
        morganAnswersWithAnteMessage(anteMessage, message: message)
        dismissAutoResponsePane()
    }
    
    /*
     * Dismisses auto-response
     */
    func dismissAutoResponsePane() {
        let transition = UIViewAnimationOptions.TransitionCrossDissolve
        UIView.transitionWithView(self.view, duration: 0.8, options: transition, animations: {
            self.ansView.removeFromSuperview()}, completion: nil)
        self.shouldScroll = false
    }
    
    /*
     * Bring up tix link
     */
    func showTicketsLink() {
        sendMorganMessageFromAutoRepsonseButton("Tap the action button on the top right to purchase tickets!", type: Message.MessageType.Purchase)
    }
    
    func openPurchaseUrl(buyButton : UIPurchaseButton) {

        dismissAutoResponsePane()
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)

        let buyAction = UIAlertAction(title: "Open in Safari", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: buyButton.buyLink)!)
            
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
                dismissAutoResponsePane()
        sendMorganMessageFromAutoRepsonseButton("Here! Tap the play button in the top right corner to hear some tunes by this artist", type: Message.MessageType.Preview)
    }
    
    func showNextResult() {
        gIndex++
        Server.postToServer(latestQuery, lat: Double(userLoc.latitude), lon: Double(userLoc.longitude), index:gIndex)
        dismissAutoResponsePane()
        showMorganIsTyping()
    }
    
    func showMorganIsTyping() {
        typingLabel.hidden = false
    }
    
    func removeMorganIsTyping() {
        typingLabel.hidden = true
    }
}
