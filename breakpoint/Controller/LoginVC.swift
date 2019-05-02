//
//  LoginVC.swift
//  breakpoint
//
//  Created by Caleb Stultz on 7/24/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Firebase


class LoginVC: UIViewController {

    @IBOutlet weak var emailField: InsetTextField!
    @IBOutlet weak var passwordField: InsetTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    @IBAction func signInBtnWasPressed(_ sender: Any) {
        if emailField.text != nil && passwordField.text != nil {
            AuthService.instance.loginUser(withEmail: emailField.text!, andPassword: passwordField.text!, loginComplete: { (success, loginError) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                    let loginBanner = NotificationBanner(title: "Successfully login!",
                                                        subtitle: "\(self.emailField.text!)",
                        style: .success) // 지우는 피드의 해당하는 이메일을 subtitle로
                    loginBanner.show()
                } else {
                    print(String(describing: loginError?.localizedDescription))
                    // 계정이 존재 하지 않음
                }
                
                AuthService.instance.registerUser(withEmail: self.emailField.text!, andPassword: self.passwordField.text!, userCreationComplete: { (success, registrationError) in
                    if success {
                        AuthService.instance.loginUser(withEmail: self.emailField.text!, andPassword: self.passwordField.text!, loginComplete: { (success, nil) in
                            
                      
                            // storage에 파일까지 생성하고 나서 dismiss, banner로 진행
                            
                            
                            print("Successfully registered user!")
                        
                            let registerBanner = NotificationBanner(title: "Successfully registered user",
                                                                      subtitle: "\(self.emailField.text!)",
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
                                
                                
                            
                                self.dismiss(animated: true, completion: nil)

                            }
                            
                            
                            // dismiss를 맨 마지막에 배치, 신규 생성은 무조건적으로 해줘야 함

                        })
                    } else {
                        print(String(describing: registrationError?.localizedDescription))
                        let errDesc = (registrationError?.localizedDescription)!
                        
                        let registErrorAlert = UIAlertController(title: errDesc, message: "", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                            (action : UIAlertAction!) -> Void in })
                        
                        registErrorAlert.addAction(okAction)
                        
                        self.present(registErrorAlert, animated: true, completion: nil) // 알람이 안뜸
                        
                    }
                })
            })
        }
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
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

extension LoginVC: UITextFieldDelegate { }
