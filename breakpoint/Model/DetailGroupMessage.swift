//
//  DetailGroupMessage.swift
//  breakpoint
//
//  Created by 김영석 on 23/02/2019.
//  Copyright © 2019 Caleb Stultz. All rights reserved.
//

import Foundation

class DetailGroupMessage {
    
    private var _groupTitle: String
    private var _content: String
    private var _email: String
    private var _messageImage: String
    private var _senderId: String
    
    var groupTitle: String {
        return _groupTitle
    }
    var content: String {
        return _content
    }
    
    var email: String {
        return _email // id가 아니라 이메일로 달려야 함
    }
    
    var messageImage: String {
        return _messageImage
    }
    
    var senderId: String {
        return _senderId
    }
    
    
    
    init(content: String, groupTitle: String, email: String, messageImage: String, senderId: String) {
        self._content = content
        self._groupTitle = groupTitle
        self._email = email
        self._messageImage = messageImage
        self._senderId = senderId
    }
}

