//
//  GoogleLoginVC.swift
//  breakpoint
//
//  Created by 김영석 on 02/01/2019.
//  Copyright © 2019 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift
import GoogleSignIn

class GoogleLoginVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    
    var usersArray = [Users]()
    // button, label, textfield

    @IBOutlet weak var googleAccountEnableLbl: UILabel!
    @IBOutlet weak var googleIdTextField: InsetTextField!
    @IBOutlet weak var googlePasswordTextField: InsetTextField!
    
    
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        var error : NSError?
        
        //setting the error
        //GGLContext.sharedInstance().configureWithError(&error)
        
        if error != nil{
            print(error ?? "google error")
            return
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self

        
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.center = view.center
        view.addSubview(googleSignInButton)
        
        googleIdTextField.isUserInteractionEnabled = false // 구글 인증 받아야 아이디가 들어감
        
  
        

      

        
        

        // Do any additional setup after loading the view.
        
        
    }
    
    //viewwilldisapper : 구글 계정 연결 되어 있으면 해제
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if GIDSignIn.sharedInstance()?.currentUser != nil {
            print("로그인 상태")
            GIDSignIn.sharedInstance().signOut()
            GIDSignIn.sharedInstance().disconnect()
            
        } else {
            print("로그아웃 상태")
            print(GIDSignIn.sharedInstance()?.currentUser)
        }
    }
    
    
//    @IBAction func signInBtnWasPressed(_ sender: Any) {
//        if googleIdTextField.text != nil && googlePasswordTextField.text != nil {
//            AuthService.instance.loginUser(withEmail: googleIdTextField.text!, andPassword: googlePasswordTextField.text!, loginComplete: { (success, loginError) in
//                if success {
//                    self.dismiss(animated: true, completion: nil)
//                    let loginBanner = NotificationBanner(title: "Successfully login!",
//                                                         subtitle: "\(self.googleIdTextField.text!)",
//                        style: .success) // 지우는 피드의 해당하는 이메일을 subtitle로
//                    loginBanner.show()
//                } else {
//                    print(String(describing: loginError?.localizedDescription))
//                    // 계정이 존재 하지 않음
//                }
//
//                AuthService.instance.registerUser(withEmail: self.googleIdTextField.text!, andPassword: self.googlePasswordTextField.text!, userCreationComplete: { (success, registrationError) in
//                    if success {
//                        AuthService.instance.loginUser(withEmail: self.googleIdTextField.text!, andPassword: self.googlePasswordTextField.text!, loginComplete: { (success, nil) in
//
//
//                            // storage에 파일까지 생성하고 나서 dismiss, banner로 진행
//
//
//                            print("Successfully registered user!")
//
//                            let registerBanner = NotificationBanner(title: "Successfully registered user",
//                                                                    subtitle: "\(self.googleIdTextField.text!)",
//                                style: .success)
//                            registerBanner.show()
//
//                            var registerImage = UIImage(named: "defaultProfileImage")
//                            registerImage = self.rotateImage(image: registerImage!)
//
//                            if let data = UIImagePNGRepresentation(registerImage!) {
//                                let storageRef = Storage.storage().reference()
//                                let defaultImageRef = storageRef.child("images/\((Auth.auth().currentUser?.email)!)_capture.png")
//
//                                let uploadTask = defaultImageRef.putData(data, metadata: nil)
//                                { (metadata, error) in
//                                    guard let metadata = metadata else {
//                                        // Uh-oh, an error occurred!
//                                        return
//                                    }
//
//                                    let size = metadata.size
//                                    defaultImageRef.downloadURL { (url, error) in
//                                        guard let downloadURL = url else {
//                                            // Uh-oh, an error occurred!
//                                            return
//                                        }
//                                    }
//
//                                }
//
//
//
//                                self.dismiss(animated: true, completion: nil)
//
//                            }
//
//
//                            // dismiss를 맨 마지막에 배치, 신규 생성은 무조건적으로 해줘야 함
//
//                        })
//                    } else {
//                        print(String(describing: registrationError?.localizedDescription))
//                        let errDesc = (registrationError?.localizedDescription)!
//
//                        let registErrorAlert = UIAlertController(title: errDesc, message: "", preferredStyle: UIAlertControllerStyle.alert)
//
//                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
//                            (action : UIAlertAction!) -> Void in })
//
//                        registErrorAlert.addAction(okAction)
//
//                        self.present(registErrorAlert, animated: true, completion: nil) // 알람이 안뜸
//
//                    }
//                })
//            })
//        }
//
//    }
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func rotateImage(image: UIImage) -> UIImage {
        
        if (image.imageOrientation == UIImageOrientation.up ) {
            return image
        }
        
        UIGraphicsBeginImageContext(image.size)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return copy!
    }
    
    //
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //if any error stop and print the error
        if error != nil{
            print(error ?? "google error")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().currentUser?.linkAndRetrieveData(with: credential) { (authResult, error) in
        
            
            print("뭔차이지?")
            print("뭘까요")
            
            // ...
        }

        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // ...
                return
            } // 구글 계정 연동 하는 로그인
              // 이 파트에서는 auth에서 계정은 생성이 된다
            
            guard let user = authResult?.user else {
                //userCreationComplete(false, error)
                return
            }
            
            var redundancyCheck = 0 // 중복성 체크
            
            // 계정이 원래 있었냐 없었냐의 문제
            // 계정을 체크를 해 줘야 한다.
            // all users email search -> 같은게 있으면 dismiss
            
//            let ref = Database.database().reference().child("users")
//            let refFeed = Database.database().reference().child("feed")
//            let userEmail = user.email
//            print(userEmail)
//
//            ref.queryOrdered(byChild: "email").queryEqual(toValue: userEmail//)
            
            
            
            DataService.instance.getAllUsers { (returnAllUsers) in

                self.usersArray = returnAllUsers.reversed()
                print("그저 테스트")
                for i in 0 ..< self.usersArray.count {
                    print("\(self.usersArray[i].email)")

                    if user.email! == self.usersArray[i].email {
                        redundancyCheck = redundancyCheck + 1
                    } else {
                        
                    }

                }
                print(user.email!)
                print(redundancyCheck)
                
                if redundancyCheck == 0 {
                    // 신규 생성
                    let userData = ["provider": user.providerID, "email": user.email, "profile": "images/\((Auth.auth().currentUser?.email)!)_capture.png"] as [String : Any] //
                    DataService.instance.createDBUser(uid: user.uid, userData: userData)
                    // DB에 계정 생성. AUTH에 이미 계정은 들어간 상태니깐
                    
                    print("Successfully registered user!")
                    
                    let registerBanner = NotificationBanner(title: "Successfully registered user",
                                                            subtitle: "\((Auth.auth().currentUser?.email)!)",
                        style: .success)
                    registerBanner.show()
                    
                    var registerImage = UIImage(named: "defaultProfileImage")
                    registerImage = self.rotateImage(image: registerImage!)
                    
                    if let data = UIImagePNGRepresentation(registerImage!) {
                        let storageRef = Storage.storage().reference()
                        let defaultImageRef = storageRef.child("images/\((Auth.auth().currentUser?.email)!)_capture.png")
                        
                        let uploadTask = defaultImageRef.putData(data, metadata: nil)
                        { (metadata, error) in
                            guard let metadata = metadata else {
                                // Uh-oh, an error occurred!
                                return
                            }
                            
                            let size = metadata.size
                            defaultImageRef.downloadURL { (url, error) in
                                guard let downloadURL = url else {
                                    // Uh-oh, an error occurred!
                                    return
                                }
                            }
                            
                        }
                        
                        
                        
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    // 걍 로그인
                    let loginBanner = NotificationBanner(title: "Successfully Login",
                                                         subtitle: "\((Auth.auth().currentUser?.email)!)",
                        style: .success)
                    loginBanner.show()
                    self.dismiss(animated: true, completion: nil)
                }

            }
         
            
            

            
             //self.dismiss(animated: true, completion: nil)
            
            
            
              // 여기에 다 때려 박아야 함
              // 3. 계정 삭제시 구글 연동 계정은 별도의 패스워드 요구 x
           
            
            
            // User is signed in
            // ...
        }
        //if success display the email on label
        googleIdTextField.text = user.profile.email
        
        // 구글 계정은 근본적으로 비밀번호를 요구 하긴 하는건가?
        googleAccountEnableLbl.text = "Connecting : \(user.profile.email!)"
        
      
        
        if GIDSignIn.sharedInstance()?.currentUser != nil {
            print("로그인 상태")
            print(GIDSignIn.sharedInstance()?.currentUser)
            print((GIDSignIn.sharedInstance()?.currentUser.profile.email)!)
            print("되는 상태")
            
         
        } else {
            print("로그아웃 상태")
            print(GIDSignIn.sharedInstance()?.currentUser)
            print(GIDSignIn.sharedInstance()?.currentUser.profile.email)
            print("안되는 상태")
        }
    }
    
    
    @IBAction func signoutbtn(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        googleIdTextField.text = ""
        googleAccountEnableLbl.text = "NOT CONNECTING GOOGLE ACCOUNT"
        // 로그인 되어있을떄에만 이용가능
        if GIDSignIn.sharedInstance()?.currentUser != nil {
            print("로그인 상태")
            print(GIDSignIn.sharedInstance()?.currentUser)
            

        } else {
            print("로그아웃 상태")
            print(GIDSignIn.sharedInstance()?.currentUser)
      
        }
    }
    
    
    
    
    @IBAction func adminBtnWasPressed(_ sender: Any) {
        
        let adminAlertController = UIAlertController(title: "관리자 비밀번호 입력", message: "", preferredStyle: UIAlertControllerStyle.alert)
        adminAlertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Your Password"
        }
        
        let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { alert -> Void in
            
            let passwordField = adminAlertController.textFields![0] as UITextField
            print("\(passwordField.text!)")
            
            if (passwordField.text!) == "1" {
                // enter admind menu
                let AdminMenuUsersVC = self.storyboard?.instantiateViewController(withIdentifier: "AdminMenuUsersVC")
                self.present(AdminMenuUsersVC!, animated: true, completion: nil)
                
            } else {
                let passwordErrorAlert = UIAlertController(title: "비밀번호 불일치", message: "", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                    (action : UIAlertAction!) -> Void in })
                
                passwordErrorAlert.addAction(okAction)
                
                self.present(passwordErrorAlert, animated: true, completion: nil) // 알람이 안뜸
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        adminAlertController.addAction(okAction)
        adminAlertController.addAction(cancelAction)
        
        self.present(adminAlertController, animated: true, completion: nil)
        
    }
    


}

// logout + 현재 계정 연동이 되어있는 상태인가? 에 대한 show

// 1. 구글 게정 연동에 대한 직관적인 UI
// 2. 구글 계정 연동 이후 로그인시 auth에서 이메일이 아닌 구글 계정 으로 찍히게
// 3. db에서는 어떻게 계정이 찍히는가?


extension GoogleLoginVC: UITextFieldDelegate { }
