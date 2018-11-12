//
//  CreatePostVC.swift
//  breakpoint
//
//  Created by Caleb Stultz on 7/24/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class CreatePostVC: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        sendBtn.bindToKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let uid = (Auth.auth().currentUser?.uid)!
        self.emailLbl.text = Auth.auth().currentUser?.email
        
        let storageRef = Storage.storage().reference().child("images/\((Auth.auth().currentUser?.email)!)_capture.png")
        
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
                self.profileImage.image = UIImage(named: "defaultProfileImage")
            } else {
                self.profileImage.image = UIImage(data: data!)
            
            }
        }

    }
    @IBAction func sendBtnWasPressed(_ sender: Any) {
        if textView.text != nil && textView.text != "Say something here..." {
            sendBtn.isEnabled = false
            let uid = (Auth.auth().currentUser?.uid)!
            
            DataService.instance.getImage(forUID: uid) { (feedProfile) in
                
            DataService.instance.uploadPost(withMessage: self.textView.text, forUID: uid, withGroupKey: nil, profileImage: feedProfile, sendComplete: { (isComplete) in // uploadPost시 이미지까지 싹다 해야?, 아니면 계정은 연결되어있으니 상관 없나? -> 이미 feedProfile이 있다!
                if isComplete {
                    self.sendBtn.isEnabled = true
                    self.dismiss(animated: true, completion: nil)
                    
                    let newPostCreatebanner = NotificationBanner(title: "Suceess! New Feed Created!",
                                                    subtitle: "\((Auth.auth().currentUser?.email)!)",
                                                    style: .success)
                    newPostCreatebanner.show()

                    // 알림이 떠 줘야 함
                    
                } else {
                    self.sendBtn.isEnabled = true
                    print("There was an error!")
                }
            })
                
            
            
        }
        }
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreatePostVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
}






