//
//  AdminMenuVC.swift
//  breakpoint
//
//  Created by 김영석 on 13/11/2018.
//  Copyright © 2018 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

var detailEmail = ""
var detailProfile = ""
var detailUID = ""

class AdminMenuUsersVC: UIViewController {
    
    
  
    @IBOutlet weak var tableView: UITableView!
    
    var usersArray = [Users]()
    var feedArray = [Message]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataService.instance.getAllUsers { (returnAllUsers) in
            
            self.usersArray = returnAllUsers.reversed()
            self.tableView.reloadData()
            print("그저 테스트")
           
        }
        
        DataService.instance.getAllFeedMessages { (loadFeed) in
            
            self.feedArray = loadFeed.reversed()
            print("feed \(self.feedArray.count)")
            let ct = self.feedArray.count
            for i in 0 ..< self.feedArray.count {
                print("\(self.feedArray[i].senderId)")
                print("\(self.feedArray[i].content)")
                
            } // 불러오는거 완료
        }
        
        // senderid
        
    }
    
    
    @IBAction func closeBtnWasClosed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    

}

extension AdminMenuUsersVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "adminUserCell") as? AdminUserCell else { return UITableViewCell() }
        
        let users = usersArray[indexPath.row]
        
        // load 해야할 것 들 : profile image, email. 전용키 senderID (별도로 뽑아 내 줘야 함)
        // profile
        // senderID
        
        print(users.email) // 이메일
        print(users.profile) // profile
        
        
        let storageRef = Storage.storage().reference().child("\(users.profile)")
        let ref = Database.database().reference().child("users") // users
        
        ref.queryOrdered(byChild: "email").queryEqual(toValue: self.usersArray[indexPath.row].email).observeSingleEvent(of: .value) { (snapshot) in
            
            for child in snapshot.children {
                let snapKey = (child as AnyObject).key as String
                
                
                storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error)
                    } else {
                        
     
                        cell.configureCell(profileImage: UIImage(data: data!)!, email: users.email, SenderID: snapKey)
                    }
                }
                
                
                
                
            }
        }
        
  
    
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // click 시 뽑아 내야하는 것 : image, email, uid
        
        
        let users = usersArray[indexPath.row]
        let ref = Database.database().reference().child("users")
        print(users.email) // 이메일
        print(users.profile) // 프로필 이미지 파일
        print(users.provider)
        
        detailEmail = users.email
        detailProfile = users.profile
        
        
        ref.queryOrdered(byChild: "email").queryEqual(toValue: users.email).observeSingleEvent(of: .value) { (snapshot) in
            
            for child in snapshot.children {
                let snapKey = (child as AnyObject).key as String
                print(snapKey) // uid
                detailUID = snapKey
            }
        }
        /*"rules": {
         ".read": "auth != true",
         ".write": "auth != true"
         
         } */
        
        let AdminDetailUserVC = self.storyboard?.instantiateViewController(withIdentifier: "AdminDetailUserVC")

        self.present(AdminDetailUserVC!, animated: true, completion: nil)

        
        
    }
    

    // 직접적으로 editActionsForRowAt 해서 delete 하는건 포기
    // editActionsForRowAt > adminDetailVC > DETAIL > DELETE
    // DETAIL : MEVC와 비슷하게, delete도 그런 방식으로. 달라지는건 UID랑 FEED 내용 + GROUP에 관한 디테일까지 다
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let deleteAction = UITableViewRowAction(style: .destructive, title: "DETELE") { (rowAction, indexPath) in
//
//            var emailForSubtitle = self.usersArray[indexPath.row].email // 선택한 Email
//
//            let ref = Database.database().reference().child("users")
//            let refFeed = Database.database().reference().child("feed")
//
//            ref.queryOrdered(byChild: "email").queryEqual(toValue: self.usersArray[indexPath.row].email).observeSingleEvent(of: .value, with: { (snapshot) in
//                for child in snapshot.children {
//                    let snapKey = (child as AnyObject).key as String
//                    print(snapKey)
//                    print("아니 왜") // UID키 뽑아냄
//
//                    // snapkey, email.
//                    let user = Auth.auth().currentUser?.uid
//                    print("테스트 입니다 \(user)") // nil이라고 뜸
//
//
//                    // 1. users에서 out 시켜버리기
//                    // :
//
//                    // 2. feed와 group에서 해당 되는거 다 체크해서 골라내서 out
//
//                    ref.child(snapKey).removeValue(completionBlock: { (error, refer) in
//                        if error != nil {
//                            print(error)
//                        } else {
//                            //print(refer)
//                            print("User Removed Correctly")
//
//                            self.usersArray.remove(at: indexPath.row)
//                            self.tableView.deleteRows(at: [indexPath], with: .fade)
//                            self.tableView.reloadData()
//
//
//                            // storage에 있는 파일도 날려야 함
//                            // auth에 있는 계정도 날려야 함
//                            // group에 속해있는 계정, feed도 날려야 함
//
//                            // feed 날리기
//                                for i in 0 ..< self.feedArray.count {
//                                    //0부터 feed 갯수
//                                    if snapKey == self.feedArray[i].senderId {
//                                        print("일단 테스트")
//                                        print("삭제할려는 계정의 snapkey = feed에 있는 senderID")
//                                        let equalKey = snapKey
//
//                                        // 체크는 됨
//                                        // 삭제 - feed - 해당 feed
//                                        refFeed.queryOrdered(byChild: "senderId").queryEqual(toValue: equalKey).observeSingleEvent(of: .value, with: { (feedSnap) in
//                                            for feedChild in feedSnap.children {
//                                                let feedKey = (feedChild as AnyObject).key as String
//                                                // 삭제할려는 피드의 메인 키들
//                                                print("\(feedKey)")
//                                                refFeed.child(feedKey).removeValue(completionBlock: { (error, referFeed) in
//                                                    if error != nil {
//                                                        print(error)
//                                                } else {
//                                                    //print(refer)
//                                                    print("Feed Message Removed")
//                                                    // 제거. 확인 끝
//
//
//                                                }
//
//
//                                            })
//
//                                        }
//
//                                    })
//
//                                }
//                            }
//
//                            // Auth 날리기
//                            // uid로 날려야
//                            //
////                            Auth.auth().delete
//
//                            // 삭제를 위한
//                            // 로그인 -> 삭제 func
//                            // 이상태에서 로그인을 어떻게 할 것 ?
//                            // 별도의 ui를 만들어야 하나?
//                            // password를 받아야 하나?
//                            // 결론 : 관리자 페이지에서 계정 삭제는 불가. 로그인 상태에서 갈아 엎어야 할듯
//
//
//                            let userDeleteBanner =  NotificationBanner(title: "Suceess! Account Is Delete!",
//                                                                       subtitle: "\(emailForSubtitle)",
//                                style: .success)
//
//                            userDeleteBanner.show()
//
//
//                            DispatchQueue.main.async{
//
//                            }
//                        }
//
//
//                    })
//
//
//                }
//            })
//
//            self.tableView.reloadData()
//
//        }
//
//        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
//        return [deleteAction]
//    }
//
    
    
    // 삭제 func.
    

    // 기본적인 정보 3가지 보여주는건 가능함 (ㅇ)
    // 밀어서 삭제하는 기능 (ㅇ)
    // 삭제할시 계정 + feed에 있는 메시지 제거 + 그룹에 포함 되어있는 경우 그룹에서 out
    
    // 1. 계정은 날라감
    // 2. feed에 있는 메시지를 다 날려야 한다
    // : feed에 있는 메시지를 다 load 하고 -> 지우는 id와 senderid가 일치하면 지워지는 걸로
    
    
    
    
    // 관리자 페이지에서 유저 이름을 그냥 삭제 가능하게
    
    
    
    
}
