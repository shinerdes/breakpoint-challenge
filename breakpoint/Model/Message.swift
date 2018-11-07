//
//  Message.swift
//  breakpoint
//
//  Created by Caleb Stultz on 7/24/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import Foundation

class Message {
    private var _content: String
    private var _senderId: String
    private var _messageImage: String
    
    var content: String {
        return _content
    }
    
    var senderId: String {
        return _senderId
    }
    
    var messageImage: String {
        return _messageImage
    }
    
    init(content: String, senderId: String, messageImage: String) {
        self._content = content
        self._senderId = senderId
        self._messageImage = messageImage
    }
}
