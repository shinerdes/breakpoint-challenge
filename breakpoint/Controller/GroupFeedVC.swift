//
//  GroupFeedVC.swift
//  breakpoint
//
//  Created by Caleb Stultz on 7/25/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

var GroupKey = ""

class GroupFeedVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupTitleLbl: UILabel!
    @IBOutlet weak var membersLbl: UILabel!

    
    var group: Group?
    var groupMessages = [Message]()
    
    func initData(forGroup group: Group) {
        self.group = group
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        GroupKey = (group?.key)!

    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTitleLbl.text = group?.groupTitle
        DataService.instance.getEmailsFor(group: group!) { (returnedEmails) in
            self.membersLbl.text = returnedEmails.joined(separator: ", ")
           
        }
        
        DataService.instance.REF_GROUPS.observe(.value) { (snapshot) in
            DataService.instance.getAllMessagesFor(desiredGroup: self.group!, handler: { (returnedGroupMessages) in
                self.groupMessages = returnedGroupMessages.reversed()
                self.tableView.reloadData()
                
        
//                if self.groupMessages.count > 0 {
//                    self.tableView.scrollToRow(at: IndexPath(row: self.groupMessages.count - 1, section: 0), at: .none, animated: true)
//                }
            })
        }
    }
    
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        dismissDetail()
    }
    
    
}

extension GroupFeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessages.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupFeedCell", for: indexPath) as? GroupFeedCell else { return UITableViewCell() }
        let message = groupMessages[indexPath.row]
    
        
        DataService.instance.getUsername(forUID: message.senderId) { (email) in
            
            DataService.instance.getImage(forUID: message.senderId, handler: { (returnedProfile) in
                
            let storageRef = Storage.storage().reference().child("\(returnedProfile)")
                
                
                storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error)
                    } else {
                        
                        cell.configureCell(profileImage: UIImage(data: data!)!, email: email, content: message.content)
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
            
            let ref = Database.database().reference().child("groups").child(GroupKey).child("messages") // 여기까지는 1차적으로 뽑아냄
            var emailForSubtitle = ""
            DataService.instance.getUsername(forUID: self.groupMessages[indexPath.row].senderId, handler: { (returnedemail) in
                emailForSubtitle = returnedemail
            })
            
            ref.queryOrdered(byChild: "content").queryEqual(toValue: self.groupMessages[indexPath.row].content).observeSingleEvent(of: .value, with: { (snapshot) in
                print(self.groupMessages[indexPath.row].content)
                for child in snapshot.children {
                    let snapKey = (child as AnyObject).key as String
                    print(snapKey) // snap 키를 불러옴
                
                    ref.child(snapKey).removeValue(completionBlock: { (error, refer) in
                        if error != nil {
                            print(error)
                        } else {
                            print(refer)
                            print("Child Removed Correctly")
                            
                            let groupPostDeleteBanner = NotificationBanner(title: "Suceess! Feed Is Delete!",
                                                                      subtitle: "\(emailForSubtitle)",
                                style: .danger) // 지우는 피드의 해당하는 이메일을 subtitle로
                            groupPostDeleteBanner.show()
                            
                        
                            DispatchQueue.main.async{
                                
                            }
                        }
                    })
                }
            })
            
          
            
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        return [deleteAction]
        
    }
    

}















