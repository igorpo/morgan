//
//  Server.swift
//  Morgan
//
//  Created by Yagil Burowski on 3/29/15.
//  Copyright (c) 2015 CIS350FTW. All rights reserved.
//

import UIKit

class Server: NSObject {
 
    class func postToServer(rawUserInput : String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://jbartolozzi.pythonanywhere.com/morgan/query")!)
        request.HTTPMethod = "POST"
        let postString = "raw_user_data=" + rawUserInput
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            println("response = \(response)")
            
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("responseString = \(responseString)")
        }
        task.resume()
    }
    
}
