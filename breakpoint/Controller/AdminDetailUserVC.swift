//
//  AdminDetailUserVC.swift
//  breakpoint
//
//  Created by 김영석 on 10/02/2019.
//  Copyright © 2019 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase

var detailUserFeedArray = [Message]()
var detailUserGroupArray = [DetailGroupMessage]()


class AdminDetailUserVC: UIViewController {
    
    
    @IBOutlet weak var testbtn: UIButton!
    var messageArray = [Message]()
    var groupsArray = [DetailGroupMessage]()
    var delayArray = [Message]()

    @IBOutlet weak var detailProfileImg: UIImageView!
    @IBOutlet weak var detailEmailLbl: UILabel!
    @IBOutlet weak var detailUIDLbl: UILabel!
    @IBOutlet weak var detailFeedBtn: UIButton!
    @IBOutlet weak var detailGroupFeedBtn: UIButton!
    @IBOutlet weak var detailProvideImg: UIImageView!
    @IBOutlet weak var detailExitBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let storageRef = Storage.storage().reference().child(detailProfile) // 사진이나 아이콘 자체는 계속 저장되어있음

        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error) // 처음에 불러올때 시간차가 생기니깐 다시 해본다?

            } else {
                self.detailProfileImg.image = UIImage(data: data!)

            }
        }
        
        detailEmailLbl.text = detailEmail
        detailUIDLbl.text = ("UID : \(detailUID)")
        
        if detailEmail.contains("@gmail.com") {
            print("exists")
            self.detailProvideImg.image = UIImage(named: "google")
            
            // 구글 이미지
        } else {
            print("not exists")
            self.detailProvideImg.image = UIImage(named: "email")
            
            
            // 이메일 이미지
        }
        
        print(detailEmail)
        print(detailUID)
        print(detailProfile)
        
        DataService.instance.getGroup(forUID: detailUID) { (snaparray) in // uid -> array return // 왜 3번이 돌고 2번이 돌까?
            detailUserGroupArray = snaparray.reversed()
         
            var detailGroupFeedCount = 0
         
            // 중간과정을 한번 더 겪는 장치가 필요?
        
            
        }
    }
    
    
    @IBAction func detailExitBtnWasPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        detailUserGroupArray.removeAll()
    }

    
    

    
    
    @IBAction func DetailFeedBtnWasPressed(_ sender: Any) {
        let AdminDetailFeedVC = self.storyboard?.instantiateViewController(withIdentifier: "AdminDetailFeedVC")
        // feed 갯수를 사전에 넘겨줘야 할듯
        
        // 전체 FEED 체크 -> uid 같은거 확인 후 배열로 추가
        
        DataService.instance.getAllFeedMessages { (returnedMessagesArray) in
            self.messageArray = returnedMessagesArray.reversed()
            
            var detailFeedCount = 0
            
            if self.messageArray.count > 0 {
                for i in 0 ..< self.messageArray.count { //0부터 messageArray.count까지 카운트
                    let messageUID = self.messageArray[i].senderId
                    print("메시지 array \(self.messageArray[i].senderId)")
                    print("디테일 \(detailUID)")
                    if messageUID == detailUID {
                        
                        detailUserFeedArray.append(self.messageArray[i])
                        detailFeedCount = detailFeedCount + 1
                       
                     // 일치 하면 detailUserFeedArray에 추가 시켜버린다
                        
                    }
                    
                    
                }
            }
            
            print("몇번도는지 한번 봅시다")
            
            self.present(AdminDetailFeedVC!, animated: true, completion: nil)

        }
        
        
        
    }
    
    @IBAction func DetailGroupFeedBtnWasPressed(_ sender: Any) {
        let AdminDetailGroupFeedVC = self.storyboard?.instantiateViewController(withIdentifier: "AdminDetailGroupFeedVC")
        print("아니 왜 \(detailUserGroupArray.count)")
        print("대체 왜 \(detailUserFeedArray.count)")
        
        // 여기서 먼저 보내기
        
        
//        DataService.instance.getGroup(forUID: detailUID) { (snaparray) in // uid -> array return // 왜 3번이 돌고 2번이 돌까?
//            detailUserGroupArray = snaparray.reversed()
//            print("갯수봅시다 \(self.groupsArray.count)") // 받아온 갯수
//            var detailGroupFeedCount = 0

//
//            // 중간과정을 한번 더 겪는 장치가 필요?
//            //self.present(AdminDetailGroupFeedVC!, animated: true, completion: nil)
//
////             DataService.instance.getAllFeedMessages { (returnedMessagesArray) in
////                self.delayArray = returnedMessagesArray.reversed()
////                print("몇번 돌아가나 ")
////            }
//
//        }
        
        
        
        print("몇번 돌아가나 보자")
        //여기서 보내버리면 이거 타이밍이 나오나
        self.present(AdminDetailGroupFeedVC!, animated: true, completion: nil)
}
    
    
    
  
}
