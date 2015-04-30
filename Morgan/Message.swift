//
//  Message.swift
//  Morgan
//
//  Created by Yagil Burowski on 3/24/15.
//  Copyright (c) 2015 CIS350FTW. All rights reserved.
//

import UIKit

class Message: NSObject {

    enum MessageType {
        case Regular, Preview, Purchase
    }
    
    var content: String = ""
    var isMorgan: Bool
    var artist: String = ""
    var previewImgUrl : String = ""
    var lon : Double = 0
    var lat : Double = 0
    var buyLink : String = ""
    
    
    var type : MessageType
    

    // 0 = regular
    // 1 = preview
    // 2 = purchase
    
    init(content: String, isMorgan: Bool) {
        self.content = content
        self.isMorgan = isMorgan
        self.type = MessageType.Regular
    }

//    init(content: String, isMorgan: Bool, type: MessageType) {
//        self.content = content
//        self.isMorgan = isMorgan
//        self.type = type
//    }

    init(content: String, isMorgan: Bool, type: MessageType, artist: String, previewImgUrl: String) {
        self.content = content
        self.isMorgan = isMorgan
        self.type = type
        self.artist = artist
        self.previewImgUrl = previewImgUrl
    }

    init(content: String, isMorgan: Bool, type: MessageType, lon: Double, lat: Double, buyLink: String) {
        self.content = content
        self.isMorgan = isMorgan
        self.type = type
        self.lon = lon
        self.lat = lat
        self.buyLink = buyLink
    }
    
    func getType() -> MessageType {
        return type
    }
    
    
}
