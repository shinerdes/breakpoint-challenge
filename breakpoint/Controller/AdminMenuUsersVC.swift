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
     
        
        let AdminDetailUserVC = self.storyboard?.instantiateViewController(withIdentifier: "AdminDetailUserVC")

        self.present(AdminDetailUserVC!, animated: true, completion: nil)

        
        
    }
    

   
    
    
    
    
}
