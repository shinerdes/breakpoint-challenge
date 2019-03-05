//
//  AdminDetailGroupFeedVC.swift
//  breakpoint
//
//  Created by 김영석 on 14/02/2019.
//  Copyright © 2019 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class AdminDetailGroupFeedVC: UIViewController {
    
    
    var groupMessageArray = [DetailGroupMessage]()
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 애초에 LOAD되어있을떄 array가 완성 되어있는 상태로
    }
    
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        detailUserGroupArray.removeAll()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func testbtnwaspressed(_ sender: Any) {
        tableView.reloadData()
        print("리프레쉬")
    }
    
    func getGroupUID() {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AdminDetailGroupFeedVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailUserGroupArray.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailGroupFeedCell") as? DetailGroupFeedCell else { return UITableViewCell() }
        
            let message = detailUserGroupArray[indexPath.row]
        
        
                    
            let storageRef = Storage.storage().reference().child("\(message.messageImage)") // 사진이나 아이콘 자체는 계속 저장되어있음
                    
                    // returnedProfile = image/tt@tt.com_camera.png
                    // 여기서 이미지를 불러와서 때려 박아줘야 함
                    
                    storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error)
                        } else {
                            
                            cell.configureCell(profileImage: UIImage(data: data!)!, email: message.email, title: message.groupTitle, content: message.content)
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
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            
        var snapKey2 = ""
        print(detailUserGroupArray[indexPath.row].groupTitle)
        var ref1 = ""
            
            // 여기서 groupkey를 받아야 함
            
            // 키 안받고 넘겨야 함
            
            
            
            //print(snapKey2)

            Database.database().reference().child("groups").queryOrdered(byChild: "title").queryEqual(toValue: detailUserGroupArray[indexPath.row].groupTitle).observeSingleEvent(of: .value, with: { (data) in
                for uid in data.children
                {
                    print(uid)
                    ref1 = (uid as AnyObject).key as String
                    print(ref1)
                }
            
           
            
            print("ref1 \(ref1)")
            let ref = Database.database().reference().child("groups").child(ref1).child("messages")
            // groupkey를 뽑아내줘야함
            print("이게 맞나 \(Database.database().reference().child("groups").childByAutoId().child("messages").childByAutoId().child("content"))")
            var emailForSubtitle = ""
            DataService.instance.getUsername(forUID: detailUserGroupArray[indexPath.row].senderId, handler: { (returnedemail) in
                emailForSubtitle = returnedemail // 그냥 email 뽑아내기
            })
                
                ref.queryOrdered(byChild: "content").queryEqual(toValue: detailUserGroupArray[indexPath.row].content).observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    print(detailUserGroupArray[indexPath.row].content)
                    for child in snapshot.children {
                        let snapKey = (child as AnyObject).key as String
                        print("이게 안되나 \(snapKey)")// snap 키를 불러옴
                        
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
                                    self.tableView.beginUpdates()
                                    self.tableView.endUpdates()
                                    self.tableView.reloadData()
                                }
                                
                                // 삭제 되면 그냥 넘기는걸로
                                self.dismiss(animated: true, completion: nil)
                                
                            }
                            
                        })
                        
                    }
                    
                    
                })

                
        })
        
        print("굴러가는거 테스트")
//            ref.queryOrdered(byChild: "content").queryEqual(toValue: detailUserGroupArray[indexPath.row].content).observeSingleEvent(of: .value, with: { (snapshot) in
//                print(snapshot)
//                print(detailUserGroupArray[indexPath.row].content)
//                for child in snapshot.children {
//                    let snapKey = (child as AnyObject).key as String
//                    print("이게 안되나 \(snapKey)")// snap 키를 불러옴
//
//                    ref.child(snapKey).removeValue(completionBlock: { (error, refer) in
//                        if error != nil {
//                            print(error)
//                        } else {
//                            print(refer)
//                            print("Child Removed Correctly")
//
//                            let groupPostDeleteBanner = NotificationBanner(title: "Suceess! Feed Is Delete!",
//                                                                           subtitle: "\(emailForSubtitle)",
//                                style: .danger) // 지우는 피드의 해당하는 이메일을 subtitle로
//                            groupPostDeleteBanner.show()
//
//
//
//
//                            DispatchQueue.main.async{
//
//
//                            }
//
//
//                            }
//
//                           })
//
//                      }
//
//
//                    })

             
   
            self.tableView.reloadData()
        }
        
        
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        return [deleteAction]

    }

    
    
    
    
}
