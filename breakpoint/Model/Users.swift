//
//  Users.swift
//  breakpoint
//
//  Created by 김영석 on 14/11/2018.
//  Copyright © 2018 Caleb Stultz. All rights reserved.
//

import Foundation

class Users {

    
    private var _email: String
    private var _profile: String
    private var _provider: String
    
    var email: String {
        return _email
    }
    
    var profile: String {
        return _profile
    }
    
    var provider: String {
        return _provider
    }
    
    init(email: String, profile: String, provider: String) {
        self._email = email
        self._profile = profile
        self._provider = provider
    }
    
}
