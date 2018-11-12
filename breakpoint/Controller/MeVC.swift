//
//  MeVC.swift
//  breakpoint
//
//  Created by Caleb Stultz on 7/24/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase

class MeVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
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
    
    
    
}











