//
//  FirstViewController.swift
//  breakpoint
//
//  Created by Caleb Stultz on 7/22/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class FeedVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var messageArray = [Message]() // Feed araay
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataService.instance.getAllFeedMessages { (returnedMessagesArray) in
            self.messageArray = returnedMessagesArray.reversed()
            self.tableView.reloadData()
        }
        
    }
    
    
    
    

}

extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell") as? FeedCell else { return UITableViewCell() }
        
        let message = messageArray[indexPath.row]
        
        DataService.instance.getUsername(forUID: message.senderId) { (returnedUsername) in
            DataService.instance.getImage(forUID: message.senderId, handler: { (returnedProfile) in
                
               
     
                let storageRef = Storage.storage().reference().child("\(returnedProfile)") // 사진이나 아이콘 자체는 계속 저장되어있음
                
                // returnedProfile = image/tt@tt.com_camera.png
                // 여기서 이미지를 불러와서 때려 박아줘야 함
                
                storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error)
                    } else {
                        
                        cell.configureCell(profileImage: UIImage(data: data!)!, email: returnedUsername, content: message.content)
                    }
                }
                
              
             
            })
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            var emailForSubtitle = ""
            let ref = Database.database().reference().child("feed")
           
            DataService.instance.getUsername(forUID: self.messageArray[indexPath.row].senderId, handler: { (returnedemail) in
                emailForSubtitle = returnedemail
            })
            
            ref.queryOrdered(byChild: "content").queryEqual(toValue: self.messageArray[indexPath.row].content).observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                    let snapKey = (child as AnyObject).key as String
                    print(snapKey) // snap 키를 불러옴
                    "" // 단순하게 이메일만 뽑아서 서브타이블로 집어넣기
                    
                    ref.child(snapKey).removeValue(completionBlock: { (error, refer) in
                        if error != nil {
                            print(error)
                        } else {
                            print(refer)
                            print("Child Removed Correctly")
                            
                            self.messageArray.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                            self.tableView.reloadData()
                            
                            let postDeleteBanner = NotificationBanner(title: "Suceess! Feed Is Delete!",
                                                                         subtitle: "\(emailForSubtitle)",
                                style: .danger) // 지우는 피드의 해당하는 이메일을 subtitle로
                            postDeleteBanner.show()
                            

                            DispatchQueue.main.async{
                                
                            }
                        }
                    })
                    
                }
            })
            
            self.tableView.reloadData()
            
            // firebase database delete
            // tableview reload
 
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        return [deleteAction]

    }
    
}


// 삭제나 추가시 alert 효과
// 
