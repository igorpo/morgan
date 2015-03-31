//
//  ViewController.swift
//  Morgan
//
//  Created by Yagil Burowski on 3/24/15.
//  Copyright (c) 2015 CIS350FTW. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    
    let BOTTOM_CONSTRAINT: CGFloat = 10.0

    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var sendConstraint: NSLayoutConstraint!
    @IBOutlet var txtFieldConstraint: NSLayoutConstraint!
    var messages: [Message] = []
//    var randomAnswers: [String] = ["Hmm... I'll get back to you", "On it, gimme a sec!", "Sorry, I don't understand", "That's what I thought", "Yup, sounds good", "Let me tell you a story", "Band or DJ?", "Fuck off!", "Pleased to meet you!", "You're clearly a potato", "I really like you, we should go out...sike", "I don't really know, tell me more", "I love you too!", "The wonderful world of OZ!"]
    var randomAnswers: [String] = ["this is a rlly kf ejrf ejrkf ewjkrf ewrjkf ewjrkf erwjewrjk ewjkrg ewkrg werkg ewtg ejkt jrtk rtkj erk erjj ekj fewjr wjer gejkg ejkg ejg ergrejg kjrg jwke gkjr g rgjkwg dgbg is an idiofgft omgfg wagvs fg i fg gvf  yougbgbgr gberg! this is a rlly kf ejrf ejrkf ewjkrf ewrjkf ewjrkf erwjewrjk ewjkrg ewkrg werkg ewtg ejkt jrtk rtkj erk erjj ekj fewjr wjer gejkg ejkg ejg ergrejg kjrg jwke gkjr g rgjkwg kierahf wfds if ht ric j rjh f bubbles!"]
    
    /*
     * Sends a message from the user
     */
    @IBAction func sendMessage(sender: AnyObject) {
        if messageTextField.text != "" {
            var message:Message = Message(content: messageTextField.text, isMorgan: false)
            messages.append(message)
//            Server.postToServer(message.content)
            updateTableView()
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: Selector("morganAnswers"), userInfo: nil, repeats: false)
        } else {
            
        }
        messageTextField.text = ""
    }
    
    /*
     * Morgan's response (random for now)
     */
    func morganAnswers () {
        let randomIndex = Int(arc4random_uniform(UInt32(randomAnswers.count)))
        var content = randomAnswers[randomIndex]
        var message:Message = Message(content: content, isMorgan: true)
        messages.append(message)
        updateTableView()
    }
    
    /*
     * Here we add delegates to TableView, and TextField, along with dynamic resizing of cells based on their content.
     * We also set the keyboard observers to capture all events with the keyboard popping up. 
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        messageTextField.delegate = self
        
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

        txtFieldConstraint.constant = BOTTOM_CONSTRAINT
        sendConstraint.constant = BOTTOM_CONSTRAINT
    }
    
   /*
    * Apple's standard.bullshit
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
        
        
        
        var theLabel : UILabel = cell.viewWithTag(1) as UILabel
        theLabel.lineBreakMode = .ByWordWrapping
        theLabel.numberOfLines = 0
        theLabel.text = messages[indexPath.row].content

        theLabel.sizeToFit()
        let numCharsInLabel = countElements(theLabel.text!)
        if (numCharsInLabel < 26 && cellIdentifier == "userMessageCell") {
            theLabel.textAlignment = .Right
        }

        
        if cellIdentifier == "morganCell" {
            let size = NSString(string: theLabel.text!).sizeWithAttributes([NSFontAttributeName: theLabel.font])
//            println("Width of text: \(size.width)")
//            println("x coord of label: \(theLabel.frame.origin.x)")
//            println("size of label: \(theLabel.frame.size.width)")
//            println("--------------------------------")
            let setTxtWidth = (numCharsInLabel < 26) ? size.width : size.width / ((CGFloat) (numCharsInLabel / 32))
            let rect = CGRectMake(theLabel.frame.origin.x,
                theLabel.frame.origin.y,
                setTxtWidth,
                theLabel.frame.height)
            let bubbleView: UIView = UIView(frame: rect)
            bubbleView.layer.borderColor = UIColor.purpleColor().CGColor
            bubbleView.backgroundColor = UIColor.purpleColor()
            theLabel.textColor = UIColor.whiteColor()
            bubbleView.layer.borderWidth = 1
            bubbleView.layer.cornerRadius = 12
            bubbleView.bounds = CGRectInset(bubbleView.frame, -6, -6)
            cell.contentView.addSubview(bubbleView)
            cell.contentView.sendSubviewToBack(bubbleView)
        } else if cellIdentifier == "userMessageCell" {
            let size = NSString(string: theLabel.text!).sizeWithAttributes([NSFontAttributeName: theLabel.font])
            let widthOfScreen = UIScreen.mainScreen().applicationFrame.width
            let rect = CGRectMake(widthOfScreen - size.width - 14,
                theLabel.frame.origin.y + size.height - 7,
                size.width,
                size.height)
            
            let bubbleView: UIView = UIView(frame: rect)
            bubbleView.layer.borderColor = UIColor.blueColor().CGColor
            bubbleView.backgroundColor = UIColor.blueColor()
            theLabel.textColor = UIColor.whiteColor()
            bubbleView.layer.borderWidth = 1
            bubbleView.layer.cornerRadius = 12
            bubbleView.bounds = CGRectInset(bubbleView.frame, -6, -6)
            cell.addSubview(bubbleView)
            cell.sendSubviewToBack(bubbleView)
            
//            let back = UIView(frame: cell.contentView.bounds)
//            back.backgroundColor = UIColor.whiteColor()
//            cell.addSubview(back)
//            cell.sendSubviewToBack(back)
        }

        
        
        return cell
    }
    
   /*
    * Properly reloads the messages in the conversation to move them accordingly.
    */
    func updateTableView() {
        self.tableView.reloadData()
        if self.tableView.contentSize.height > self.tableView.frame.size.height {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: messages.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }
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
}
