//
//  AuthService.swift
//  breakpoint
//
//  Created by Caleb Stultz on 7/24/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import Foundation
import Firebase

class AuthService { // 인증서비스
    static let instance = AuthService()
    
    
    
    
    
    func registerUser(withEmail email: String, andPassword password: String, userCreationComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard let user = authResult?.user else {
                userCreationComplete(false, error)
                return
            }
            
            
//            guard let user = user else {
//                userCreationComplete(false, error)
//                return
//            }
//
//
            
            
            let userData = ["provider": user.providerID, "email": user.email, "profile": "images/\((Auth.auth().currentUser?.email)!)_capture.png"] as [String : Any] //           provide , email, imagefile
            
            
            // 기본 url 설정을 해줘야 들어감 . photoUrl init이 필요할듯.
            
            
            
            DataService.instance.createDBUser(uid: user.uid, userData: userData)
            userCreationComplete(true, nil)
        }
    }
    
    func loginUser(withEmail email: String, andPassword password: String, loginComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                loginComplete(false, error)
                return
            }
            loginComplete(true, nil)
        }
    }
}


