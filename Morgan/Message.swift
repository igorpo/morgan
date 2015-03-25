//
//  Message.swift
//  Morgan
//
//  Created by Yagil Burowski on 3/24/15.
//  Copyright (c) 2015 CIS350FTW. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    var content: String = ""
    var isMorgan: Bool
    
    init(content: String, isMorgan: Bool) {
        self.content = content
        self.isMorgan = isMorgan
    }
    
    
}
