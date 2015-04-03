//
//  Server.swift
//  Morgan
//
//  Created by Yagil Burowski on 3/29/15.
//  Copyright (c) 2015 CIS350FTW. All rights reserved.
//

import UIKit
var morganResponse: String = "N/A"
class Server: NSObject {
 
    class func postToServer(rawUserInput: String, lat: Double, lon: Double) -> Void {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://jbartolozzi.pythonanywhere.com")!)
        request.HTTPMethod = "POST"
        let postString = "user_raw_data=\(rawUserInput)&user_lat=\(lat)&user_lon=\(lon)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let queue: NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: {
            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error != nil {
                println("error=\(error)")
                return
            }
            println("Response: \(response)")
            if let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                morganResponse = responseString
                println("Response String: " + responseString)
                //morganAnsweredNotification
                NSNotificationCenter.defaultCenter().postNotificationName("morganAnsweredNotification", object: nil)
            }
            
        
        })
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
//            data, response, error in
//            
//            if error != nil {
//                println("error=\(error)")
//                return
//            }
//            
//            println("response = \(response)")
//            
//            if let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) {
//                morganResponse = responseString
//                println("responseString = \(responseString)")
//            }
//            
//        }
//        task.resume()
    }
    
}
