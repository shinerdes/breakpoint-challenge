//
//  CreateGroupPostVC.swift
//  breakpoint
//
//  Created by 김영석 on 08/11/2018.
//  Copyright © 2018 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase

class CreateGroupPostVC: UIViewController {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        sendBtn.bindToKeyboard()
      

        // Do any additional setup after loading the view.
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
    
    // 이미지 + 이메일 로드
    

    @IBAction func sendBtnWasPressed(_ sender: Any) {
        if textView.text != nil && textView.text != "Say something here..." {
            sendBtn.isEnabled = false
            let uid = (Auth.auth().currentUser?.uid)!
            
            // 현재 groupkey 뽑아내기
        
            DataService.instance.getImage(forUID: uid) { (feedProfile) in
                
                DataService.instance.uploadPost(withMessage: self.textView.text, forUID: uid, withGroupKey: GroupKey, profileImage: feedProfile, sendComplete: { (isComplete) in // uploadpost는 정상적으로 돌아감
                    if isComplete {
                        self.sendBtn.isEnabled = true
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.sendBtn.isEnabled = true
                        print("There was an error!")
                    }
                })
             
            }
        }
        
    }
    
    
    // uploadpost 부분을 그룹 메시지 전용으로 변경

    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}



extension CreateGroupPostVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
}
