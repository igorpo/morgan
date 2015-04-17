//
//  Server.swift
//  Morgan
//
//  Created by Yagil Burowski on 3/29/15.
//  Copyright (c) 2015 CIS350FTW. All rights reserved.
//

import UIKit
var morganResponse: String = "N/A"
var previewURL: String = "N/A"

class Server: NSObject {
 
    /*
     * Hit up the server for a JSON response
     */
    class func postToServer(rawUserInput: String, lat: Double, lon: Double) -> Void {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://jbartolozzi.pythonanywhere.com/")!)
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
                morganResponse = responseString as String
                println("Response String: " + (responseString as String))
                //morganAnsweredNotification
                NSNotificationCenter.defaultCenter().postNotificationName("morganAnsweredNotification", object: nil)
                
            }
            
        
        })
    }
    
    /*
     * Sprint: Test to make sure that preview song plays
     */
    class func getPreviewSong(artist_name: String) -> Void {
        var new_name = artist_name.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let request = NSMutableURLRequest(URL: NSURL(string: "https://jbartolozzi.pythonanywhere.com/\(new_name)/preview")!)
        request.HTTPMethod = "POST"
        let queue: NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: {
            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error != nil {
                println("error=\(error)")
                return
            }
            println("Response: \(response)")
            if let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                previewURL = responseString as String
                println("Response String: " + (responseString as String))
                //morganAnsweredNotification
                NSNotificationCenter.defaultCenter().postNotificationName("previewURLNotification", object: nil)
            }
            
            
        })
    }

}
