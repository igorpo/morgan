//
//  FirstViewController.swift
//  Morgan
//
//  Created by Igor Pogorelskiy on 4/28/15.
//  Copyright (c) 2015 CIS350FTW. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

   /*
    * Apple general requirements
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reset()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        if ((defaults.objectForKey("didLoadOnce")) != nil) {
            var nextViewController : UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("mainViewController") as! UIViewController
            presentViewController(nextViewController, animated: false, completion: nil)
            println("loaded already")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   /*
    * Onboarding screen switch
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showMainPage") {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(true, forKey: "didLoadOnce")
        }
    }
    
    
    let pageTitles = ["Ask Morgan about shows around you, or at a specific venue", "Use natural language, get an answer immediately", "Get song previews from your favorite live artists", "Purchase tickets easily and quickly, straight from the app"]
    var images = ["concert3.png","concert4.png","concert1.png","concert2.png"]
    var count = 0
    
    var pageViewController : UIPageViewController!
    
    /*
     * Tutorial page scrolling
     */
    @IBAction func swiped(sender: AnyObject) {
        self.pageViewController.view .removeFromSuperview()
        self.pageViewController.removeFromParentViewController()
        reset()
    }
    
   /*
    * Set up and reset pageViewController for intro
    */
    func reset() {
        /* Getting the page View controller */
        pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        /* We are substracting 30 because we have a start again button whose height is 30*/
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height + 40)
        self.addChildViewController(pageViewController)
        self.view.insertSubview(pageViewController.view, atIndex: 0)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
   /*
    * Start paging through views
    */
    @IBAction func start(sender: AnyObject) {
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! PageContentViewController).pageIndex!
        index++
        if(index >= self.images.count){
            return nil
        }
        return self.viewControllerAtIndex(index)
        
    }
    
   /*
    * Utility method for pageViewController: index handler
    */
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! PageContentViewController).pageIndex!
        if(index <= 0){
            return nil
        }
        index--
        return self.viewControllerAtIndex(index)
        
    }
    
   /*
    * Utility method for pageViewController: current image and caption setup
    */
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return nil
        }
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController") as! PageContentViewController
        
        pageContentViewController.imageName = self.images[index]
        pageContentViewController.titleText = self.pageTitles[index]
        pageContentViewController.pageIndex = index
        return pageContentViewController
    }
    
   /*
    * pageViewController delegate method
    */
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageTitles.count
    }
    
   /*
    * pageViewController delegate method
    */
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

}
