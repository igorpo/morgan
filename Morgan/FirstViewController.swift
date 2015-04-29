//
//  FirstViewController.swift
//  Morgan
//
//  Created by Igor Pogorelskiy on 4/28/15.
//  Copyright (c) 2015 CIS350FTW. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        reset()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        if ((defaults.objectForKey("didLoadOnce")) != nil) {
//                        self.performSegueWithIdentifier("showMainPage", sender: self)
            var nextViewController : UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("mainViewController") as! UIViewController
            presentViewController(nextViewController, animated: false, completion: nil)
            println("loaded already")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    @IBAction func swipeLeft(sender: AnyObject) {
        println("SWipe left")
    }
    @IBAction func swiped(sender: AnyObject) {
        
        self.pageViewController.view .removeFromSuperview()
        self.pageViewController.removeFromParentViewController()
        reset()
    }
    
    func reset() {
        /* Getting the page View controller */
        pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        /* We are substracting 30 because we have a start again button whose height is 30*/
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height + 40)
        self.addChildViewController(pageViewController)
//        self.view.addSubview(pageViewController.view)
        self.view.insertSubview(pageViewController.view, atIndex: 0)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
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
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! PageContentViewController).pageIndex!
        if(index <= 0){
            return nil
        }
        index--
        return self.viewControllerAtIndex(index)
        
    }
    
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
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
