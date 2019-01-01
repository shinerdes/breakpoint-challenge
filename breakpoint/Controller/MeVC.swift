//
//  MeVC.swift
//  breakpoint
//
//  Created by Caleb Stultz on 7/24/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Firebase

class MeVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var trashBtn: UIButton!
    
    var feedArray = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.profileImage.image = UIImage(named: "defaultProfileImage")

        
        self.emailLbl.text = Auth.auth().currentUser?.email
        
        let storageRef = Storage.storage().reference().child("images/\((Auth.auth().currentUser?.email)!)_capture.png") // 사진이나 아이콘 자체는 계속 저장되어있음
        
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error) // 처음에 불러올때 시간차가 생기니깐 다시 해본다?
                    
            } else {
                self.profileImage.image = UIImage(data: data!)
                
            }
        }
        
        
        DataService.instance.getAllFeedMessages { (loadFeed) in
            self.feedArray = loadFeed
            print("feed \(self.feedArray.count)")
        }
        
        
    }
        
    

    @IBAction func signOutBtnWasPressed(_ sender: Any) {
        let logoutPopup = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout?", style: .destructive) { (buttonTapped) in
            do {
                try Auth.auth().signOut()
                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                self.present(authVC!, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
        logoutPopup.addAction(logoutAction)
        present(logoutPopup, animated: true, completion: nil)
    }
    
    @IBAction func profilePhotoChangeBtn(_ sender: Any) { //image를 추가하는 버튼
       // guard let groupFeedVC = storyboard?.instantiateViewController(withIdentifier: "GroupFeedVC") as? GroupFeedVC else { return }
       
        
    }
    
    
    
    @IBAction func alertest(_ sender: Any) {
        // textfield, cancel, ok, label
        
        let countinue = ""
        let alertController = UIAlertController(title: "모든 데이터가 삭제됩니다", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Your Password"
        }
        // 결국엔 textfield에서 받아서 패스 시켜야 함
        
        let saveAction = UIAlertAction(title: "Remove", style: UIAlertActionStyle.default, handler: { alert -> Void in
           
            
       
            let passwordField = alertController.textFields![0] as UITextField
            
            print("모든 데이터와 FEED를 삭제")
            print("\(passwordField.text!)")
            
            ///////////////////////////////////////////////////////////////////
            // 계정 삭제
            // 현재 로그인은 되어 있는 상태다
            // handler -> logout
            let user = Auth.auth().currentUser
            var credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: passwordField.text!) // 계정은 날렸는데 비밀번호에 대한 문제
            
            // 비밀번호에 대한 문제 해결 ? -> 비밀번호 끌어오기
            // 결국엔 textfield에서 해결 해야하는 문제다
            // EmailAuthProvider.credential(withEmail email: String, password: String) -> AuthCredential

            print("\(user)")
            
            // 자격 증명을 얻어야 함 -> 즉 재인증
            
            
            user?.reauthenticate(with: credential, completion: { (error) in
                
                if let error = error {
                    print(error)
                 
                    
                    let credentialErrorAlert = UIAlertController(title: "비밀번호 불일치", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                        (action : UIAlertAction!) -> Void in })
                    
                    credentialErrorAlert.addAction(okAction)
                    
                    self.present(credentialErrorAlert, animated: true, completion: nil) // 알람이 안뜸
                } else {
                    user?.delete { (error) in // 계정은 날라가는데 출력이 안되는 상태
                        if let error = error {
                            print(error)

                            let deleteErrorAlert = UIAlertController(title: "삭제 오류", message: "", preferredStyle: UIAlertControllerStyle.alert)

                            let deleteAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                                    (action : UIAlertAction!) -> Void in })

                            deleteErrorAlert.addAction(deleteAction)

                            self.present(deleteErrorAlert, animated: true, completion: nil) // 알람이 안뜸
                            
                            
                            
                        } else {
                            
                            
                            // 그룹안에 있는거 삭제
                            
                            
                            // db에서 feed와 user, group? ( 가능 )
                            let userUID = user?.uid
                            let userEmail = user?.email
                            let refDbUsers =  Database.database().reference().child("users")
                            let refFeed = Database.database().reference().child("feed")
                            let groupref = Database.database().reference().child("groups")
                            
                            refDbUsers.queryOrdered(byChild: "email").queryEqual(toValue: userEmail).observeSingleEvent(of: .value, with: { (usershot) in
                                for child in usershot.children {
                                    let snapKey = (child as AnyObject).key as String
                                    print("UID \(snapKey)")
                                    print("아니 왜") // 현재 로그인 한 이메일 계정의 UID키 뽑아냄
                                    
                                    //slqnCVWRCtXDWuioMgtfCZxw1Vv2
                                    // uid는 뽑혀져 나옴
                                    // UID로 DATABASE USER쪽을 삭제
                                    // snapkey = userUID 상태
                                    
                                    refDbUsers.child(snapKey).removeValue(completionBlock: { (error, refer) in
                                        // database user쪽 삭제
                                        if error != nil {
                                            print(error)
                                        } else {
                                            print("DB USERS removed")
                                            //print(self.feedArray.count)
                                            
                                            // feed 제거
                                            for i in 0 ..< self.feedArray.count {
                                                if snapKey == self.feedArray[i].senderId {
                                                    print("삭제할려는 계정의 snapkey = feed에 있는 senderID")
                                                    let equalKey = snapKey
                                                    
                                                    refFeed.queryOrdered(byChild: "senderId").queryEqual(toValue: equalKey).observeSingleEvent(of: .value, with: { (feedSnap) in
                                                        for feedChild in feedSnap.children {
                                                            let feedKey = (feedChild as AnyObject).key as String
                                                            print("피드키 \(feedKey)")
                                                            
                                                            refFeed.child(feedKey).removeValue(completionBlock: { (error, referFeed) in
                                                                if error != nil {
                                                                    print(error)
                                                                } else {
                                                                    print("feed message removed")
                                                                }
                                                                
                                                            })
                                                        }
                                                    })
                                                    
                                                    
                                                }
                                                
                                                
                                            }
                                            
                                            // feed 제거
                                            // snapKey
                                            
                                            groupref.queryOrdered(byChild: "description").observeSingleEvent(of: .value, with: { (groupshot) in
                                                for child in groupshot.children { // 모든 그룹 searching
                                                    
                                                    let snapgroup = (child as AnyObject).key as String
                                                    print("그룹 UID : \(snapgroup)") // group uid
                                                    
                                                    groupref.child(snapgroup).child("members").observeSingleEvent(of: .value, with: { (membersnap) in
                                                        for member in membersnap.children {
                                                            let members = (member as AnyObject).value as String
                                                            print("멤버 UID : \(member)")
                                                            
                                                            
                                                            if snapKey == members { // snapKey == members
                                                                let removeKey = (member as AnyObject).key as String
                                                                groupref.child(snapgroup).child("members").child(removeKey).removeValue(completionBlock: { (error, referFeed) in
                                                                    
                                                                    if error != nil {
                                                                        print(error)
                                                                    } else {
                                                                        print("user deleted") // 그룹 내 유저 리스트에서 제거
                                                                    }
                                                                    
                                                                    
                                                                })
                                                            }
                                                            
                                                        }
                                                    })
                                                    
                                                    
                                                    groupref.child(snapgroup).child("messages").queryOrdered(byChild: "content").observeSingleEvent(of: .value, with: { (sendersnap) in
                                                        for groupmessage in sendersnap.children {
                                                            let groupmessageuid = (groupmessage as AnyObject).key as String // 그룹 내 message 항목의 Uid
                                                            
                                                            
                                                            groupref.child(snapgroup).child("messages").child(groupmessageuid).child("senderId").observeSingleEvent(of: .value, with: { (messageuidsnap) in
                                                                //messageID.senderid에서 도는중
                                                                
                                                                let groupmessagesenderId = ((messageuidsnap.value)!) as! String
                                                                print("메세지의 계정 UID : \(groupmessagesenderId)")
                                                                print("현재 계정 uid : \(userUID)")
                                                                
                                                                if userUID == groupmessagesenderId {
                                                                    print("good")
                                                                    // 메시지 제거
                                                                    
                                                                    groupref.child(snapgroup).child("messages").child(groupmessageuid).removeValue(completionBlock: { (error, referFeed) in
                                                                        if error != nil {
                                                                            print(error)
                                                                        } else {
                                                                            print("user deleted") // 그룹 내 message 제거
                                                                        }
                                                                        
                                                                    })
                                                                }
                                                                
                                                            })
                                                            // 접근 sender id에
                                                        }
                                                    })
                                                    
                                                    
                                                    
                                                }
                                            })
                                            
                                            
                                            // group 부분
                                            // 제거 해야할 부분 : 모든 그룹을 search -> 각 그룹에 있는 uid값 돌려서 같으면 제거, feed도 마찬가지
            
                                            
                                        }
                                        
                                    })
                                    
                                    // feed 삭제
                                    
                                    
                                }
                            })
                            
                            
                            
                            
                            
                            // image 파일 삭제 ( 가능 )
                            
                            
                            let pictureRef = Storage.storage().reference().child("images/\((userEmail)!)_capture.png")
                            pictureRef.delete { error in
                                if let error = error {
                                    print(error) // 삭제 가능
                                } else {
                                    // File deleted successfully
                                }
                            }
                            
                            
                            
                            
                            print("아니 무엇 \((user?.email)!)") // email 추출
                            
                            do {
                                try Auth.auth().signOut()
                                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                                self.present(authVC!, animated: true, completion: nil)
                            } catch {
                                print(error)
                            }
                            // authVC로 가는건 맨 마지막
                            
                            // Account deleted.
                        }
                    }
                    
                    
                    
                }
                
                
                
            })
            
            ////////////////////////////////////////////////////////////////////
            
            
            
            
            
        })
    
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    
        
        
        
    }
    
    
   
}


// 관리자 페이지를 어떻게 할 것 인가?
//









