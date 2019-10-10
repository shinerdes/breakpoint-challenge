//
//  DataService.swift
//  breakpoint
//
//  Created by Caleb Stultz on 7/22/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import Foundation
import Firebase



let DB_BASE = Database.database().reference()




class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GROUPS = DB_BASE.child("groups")
    private var _REF_FEED = DB_BASE.child("feed")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_GROUPS: DatabaseReference {
        return _REF_GROUPS
    }
    
    var REF_FEED: DatabaseReference {
        return _REF_FEED
    }
   

    func cameraUploadImage(forUID uid: String, cameraImage: String) {
        REF_USERS.child(uid).child("profile").setValue(cameraImage)
    }
    
    
    func createDBUser(uid: String, userData: Dictionary<String, Any>) { // 유저 DB 생성. user - child(uid) - childData(userdata). - image는 따로
        
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
    
    // getProfileImageFileString
    func getImage(forUID uid: String, handler: @escaping (_ username: String) -> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if user.key == uid {
                    handler(user.childSnapshot(forPath: "profile").value as! String)
                }
            }
        }
    }
    
    func getGroup(forUID uid: String, handler: @escaping (_ getGroupArray: [DetailGroupMessage]) -> ()) {
        var getGroupArray = [DetailGroupMessage]() // 수정해야함
        REF_GROUPS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            print("내부 돈다") // 일단 여기는 한번 돔
            for group in userSnapshot {
                //let memberArray = group.childSnapshot(forPath: "members").value as! [String]
                
                let title = group.childSnapshot(forPath: "title").value as! String 
                
                print("타이틀 돈다") // 방이 3개 있으니깐 3번 도는게 맞음
                //let group = Group(title: title, description: description, key: group.key, members: memberArray, memberCount: memberArray.count)
                
                Database.database().reference().child("groups").queryOrdered(byChild: "title").queryEqual(toValue: title).observeSingleEvent(of: .value, with: { (snapshot) in
                    //
                    for forgroupuid in snapshot.children {
                        
                        print("forgroupuid 돈다")
                        let snapKey = (forgroupuid as AnyObject).key as String
                        print("그룹 내에 있는 모든 그룹방의 uid \(snapKey)") // uid
                        // 여기서 다시 접근
                        Database.database().reference().child("groups").child(snapKey).child("messages").queryOrdered(byChild: "senderId").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (snap2) in       // 각 그룹에 있는 방 -> message방 -> senderId가 같은곳으로 돈다
                            
                            
                            guard let snap2 = snap2.children.allObjects as? [DataSnapshot] else { return }
                            for finalsnap in snap2 {
                                var count = 0
                                print("finalsnap 돈다")
                                print("\(snap2.count)")

                                let senderId = finalsnap.childSnapshot(forPath: "senderId").value as! String

                                
                                    DataService.instance.getUsername(forUID: senderId, handler: { (returnemail) in
                                        let content = finalsnap.childSnapshot(forPath: "content").value as! String// ??? null이 왜 뜰까
                                        let profile = finalsnap.childSnapshot(forPath: "profile").value as! String
                                       // let senderId = finalsnap.childSnapshot(forPath: "senderId").value as! String
                                        var email = returnemail
//                                        print("--------")
//                                        print(content)
//                                        print(profile)
//                                        print(senderId)
//                                        print(email)
//                                        print("--------")
                                        let finalsnap = DetailGroupMessage(content: content, groupTitle: title, email: email, messageImage: profile, senderId: senderId)
                                        getGroupArray.append(finalsnap)
                                      
                                        
                                        
                                        handler(getGroupArray)
                                       
                                        
                                        // 여기에 놓으면 한번에 3번 다 돔
                                    })
                            

                                
                            }// for 기점
                            
                        
                        })
               
                    }
                })
                
                
            }
           

        }
        

    }
 
   
    //profileImageSet
    func setAvatarProfile(forUID uid: String, avatarName: String){
        REF_USERS.child(uid).child("profile").setValue(avatarName)
    }
    // func getImage(forUID uid: String, handler: @escaping (_ username: String) -> ()) {
    func getUsername(forUID uid: String, handler: @escaping (_ username: String) -> ()) { //
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if user.key == uid {
                    handler(user.childSnapshot(forPath: "email").value as! String)
                }
            }
        }
    }
    
    
    
    func uploadPost(withMessage message: String, forUID uid: String, withGroupKey groupKey: String?, profileImage image: String, sendComplete: @escaping (_ status: Bool) -> ()) {
        if groupKey != nil {
            REF_GROUPS.child(groupKey!).child("messages").childByAutoId().updateChildValues(["content": message, "senderId": uid, "profile": image])
            sendComplete(true) // group
        } else {
            REF_FEED.childByAutoId().updateChildValues(["content": message, "senderId": uid, "profile": image])
            sendComplete(true)
        }
    }
    
    func getAllFeedMessages(handler: @escaping (_ messages: [Message]) -> ()) {
        var messageArray = [Message]()
        REF_FEED.observeSingleEvent(of: .value) { (feedMessageSnapshot) in
            guard let feedMessageSnapshot = feedMessageSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for message in feedMessageSnapshot {
                let content = message.childSnapshot(forPath: "content").value as! String
                let senderId = message.childSnapshot(forPath: "senderId").value as! String
                let messageImage = message.childSnapshot(forPath: "profile").value as! String //???
                let message = Message(content: content, senderId: senderId, messageImage: messageImage)
                messageArray.append(message)
            }
            
            handler(messageArray)
        }
    }
    
    func getAllMessagesFor(desiredGroup: Group, handler: @escaping (_ messagesArray: [Message]) -> ()) {
        var groupMessageArray = [Message]()
        REF_GROUPS.child(desiredGroup.key).child("messages").observeSingleEvent(of: .value) { (groupMessageSnapshot) in
            guard let groupMessageSnapshot = groupMessageSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for groupMessage in groupMessageSnapshot {
                let content = groupMessage.childSnapshot(forPath: "content").value as! String
                let senderId = groupMessage.childSnapshot(forPath: "senderId").value as! String
                let messageImage = groupMessage.childSnapshot(forPath: "profile").value as! String
                let groupMessage = Message(content: content, senderId: senderId, messageImage: messageImage)
                groupMessageArray.append(groupMessage)
            }
            handler(groupMessageArray)
        }
    }
    
    func getAllUsers(handler: @escaping (_ users: [Users]) -> ()) {
        var usersArray = [Users]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as?
                [DataSnapshot] else { return }
            
            for allUsers in userSnapshot {
                let email = allUsers.childSnapshot(forPath: "email").value as! String
                let profile = allUsers.childSnapshot(forPath: "profile").value as! String
                let provider = allUsers.childSnapshot(forPath: "provider").value as! String
                let allUsers = Users(email: email, profile: profile, provider: provider)
                usersArray.append(allUsers)
            }
            
            handler(usersArray)
        }
    }
    
    func getEmail(forSearchQuery query: String, handler: @escaping (_ emailArray: [String]) -> ()) {
        var emailArray = [String]()
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                
                if email.contains(query) == true && email != Auth.auth().currentUser?.email {
                    emailArray.append(email)
                }
            }
            handler(emailArray)
        }
    }
    
    func getIds(forUsernames usernames: [String], handler: @escaping (_ uidArray: [String]) -> ()) {
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            var idArray = [String]()
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                
                if usernames.contains(email) {
                    idArray.append(user.key)
                }
            }
            handler(idArray)
        }
    }
    
    func getEmailsFor(group: Group, handler: @escaping (_ emailArray: [String]) -> ()) {
        var emailArray = [String]()
        REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if group.members.contains(user.key) {
                    let email = user.childSnapshot(forPath: "email").value as! String
                    emailArray.append(email)
                }
            }
            handler(emailArray)
        }
    }
    
    func createGroup(withTitle title: String, andDescription description: String, forUserIds ids: [String], handler: @escaping (_ groupCreated: Bool) -> ()) {
        REF_GROUPS.childByAutoId().updateChildValues(["title": title, "description": description, "members": ids])
        handler(true)
    }
    
    func getAllGroups(handler: @escaping (_ groupsArray: [Group]) -> ()) {
        var groupsArray = [Group]()
        REF_GROUPS.observeSingleEvent(of: .value) { (groupSnapshot) in
            guard let groupSnapshot = groupSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for group in groupSnapshot {
                let memberArray = group.childSnapshot(forPath: "members").value as! [String]
                if memberArray.contains((Auth.auth().currentUser?.uid)!) {
                    let title = group.childSnapshot(forPath: "title").value as! String
                    let description = group.childSnapshot(forPath: "description").value as! String
                    let group = Group(title: title, description: description, key: group.key, members: memberArray, memberCount: memberArray.count)
                    groupsArray.append(group)
                }
            }
            handler(groupsArray)
        }
    }
}
















