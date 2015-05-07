//
//  PageContentViewController.swift
//  Morgan
//
//  Created by Igor Pogorelskiy on 4/28/15.
//  Copyright (c) 2015 CIS350FTW. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController  {

    @IBOutlet var heading: UILabel!
    @IBOutlet var bkImageView: UIImageView!
    
    var pageIndex: Int?
    var titleText : String!
    var imageName : String!
    
   /*
    * Set up page screens on load
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.heading.sizeToFit()
        self.bkImageView.image = UIImage(named: imageName)
        self.heading.text = self.titleText
        self.heading.alpha = 0.1
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.heading.alpha = 1.0
            })
        }
    }

   /*
    * Apple Memory
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
