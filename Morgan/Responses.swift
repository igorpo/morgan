//
//  Responses.swift
//  Morgan
//
//  Created by Igor Pogorelskiy on 4/30/15.
//  Copyright (c) 2015 CIS350FTW. All rights reserved.
//

import UIKit

class Responses: NSObject {
    
    class func returnShowResponseMessage() -> Message {
        var responses = ["Here's one I think you might like: ",
            "What about this show? ",
            "Called my friends and this is the hottest hit in town: ",
            "All the cool kids are going here: ",
            "Give this one a gander: "]
        let randomIndex = Int(arc4random_uniform(UInt32(responses.count)))
        return Message(content: responses[randomIndex], isMorgan: true)
    }
    
    class func returnTicketResponseMessage() -> Message {
        var responses = ["Super! You can get tickets here: ",
								"Good choice. Here you go: ",
								"Get ready for some tasty jams: ",
								"Right on. You are going to have a good time! ",
								"Awesome! Have fun, but not too much fun: "]
        let randomIndex = Int(arc4random_uniform(UInt32(responses.count)))
        return Message(content: responses[randomIndex], isMorgan: true)
    }
    
    class func returnPreviewResponseMessage() -> Message {
        var responses = ["Check this out: ",
            "Take a listen: ",
            "For your listening enjoyment, my liege: ",
            "Get a load of these tasty jams: ",
            "Maybe this will win your ear over: "]
        let randomIndex = Int(arc4random_uniform(UInt32(responses.count)))
        return Message(content: responses[randomIndex], isMorgan: true)
    }
    

}
