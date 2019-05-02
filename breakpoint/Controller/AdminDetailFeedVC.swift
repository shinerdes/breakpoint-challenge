//
//  AdminDetailFeedVC.swift
//  breakpoint
//
//  Created by 김영석 on 14/02/2019.
//  Copyright © 2019 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

// detailUID가 같은 것들
class AdminDetailFeedVC: UIViewController {
    
    var messageArray = [Message]()
   
    

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
        //detailUserFeedArray 다 비워주기
        detailUserFeedArray.removeAll()
        dismiss(animated: true, completion: nil)
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


extension AdminDetailFeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 리턴하는게 자기 가 쓴 feed의 갯수만 리턴 하는 거
        // 갯수를 새는게 아니라 array를 따로 구성해야 할듯
        
        
        return detailUserFeedArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailFeedCell") as? DetailFeedCell else { return UITableViewCell() }
        
        let message = detailUserFeedArray[indexPath.row] // 이게 문제구나
        if detailUID == message.senderId {
            print("같다")
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
        }
        // 여기서 필터링 하는게 문제

        
     
        return cell
        // 각 cell에 리턴
        
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
            
            DataService.instance.getUsername(forUID: detailUserFeedArray[indexPath.row].senderId, handler: { (returnedemail) in
                emailForSubtitle = returnedemail
            })
            
            ref.queryOrdered(byChild: "content").queryEqual(toValue: detailUserFeedArray[indexPath.row].content).observeSingleEvent(of: .value, with: { (snapshot) in
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
                            
                            detailUserFeedArray.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                            self.tableView.reloadData()
                            
                            let postDeleteBanner = NotificationBanner(title: "Suceess! Feed Is Delete!",
                                                                      subtitle: "\(emailForSubtitle)",
                                style: .danger) // 지우는 피드의 해당하는 이메일을 subtitle로
                            postDeleteBanner.show()
                            
                            
                            DispatchQueue.main.async{
                                self.dismiss(animated: true, completion: nil)
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
