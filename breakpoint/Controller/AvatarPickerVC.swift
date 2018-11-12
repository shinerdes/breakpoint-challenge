//
//  AvatarPickerVC.swift
//  breakpoint
//
//  Created by 김영석 on 2018. 10. 13..
//  Copyright © 2018년 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase

class AvatarPickerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var collectionView: UICollectionView!
    let storage = Storage.storage()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "avatarCell", for: indexPath) as? AvatarCell {
            cell.configureCell(index: indexPath.item)
            
            return cell
        }
        
        return AvatarCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let uid = (Auth.auth().currentUser?.uid)!
        //(Auth.auth().currentUser?.uid)
        //UserDataService.instance.setAvatarName(avatarName: "dark\(indexPath.item)")
        // in realtime database
        
        
        
        var imageConv = UIImage(named: "dark\(indexPath.item)") // 선택된 아이콘을 이미지로
        imageConv = rotateImage(image: imageConv!)
        
        if let data = UIImagePNGRepresentation(imageConv!) {
        let storageRef = storage.reference()
        let captureImageRef = storageRef.child("images/\((Auth.auth().currentUser?.email)!)_capture.png")
        
        let uploadTask = captureImageRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            captureImageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
            }
            
            DataService.instance.setAvatarProfile(forUID: uid, avatarName: "images/\((Auth.auth().currentUser?.email)!)_capture.png") // 이것도 스토리지에서 빼오는 걸로
            self.dismiss(animated: true, completion: nil)
        }
        
        
        // 여기서 storage에 있는 파일을 날려야 함
        // or storage에 있는 파일에 아바타 파일을 넣기
       
        }
     
        
        //


    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        

            var numOfColumns : CGFloat = 3
            if UIScreen.main.bounds.width > 320 {
                numOfColumns = 4
            }
            
            let spaceBetweenCells : CGFloat = 10
            let padding : CGFloat = 40
            let cellDimension = ((collectionView.bounds.width - padding) - (numOfColumns - 1) * spaceBetweenCells) / numOfColumns
            
            return CGSize(width: cellDimension, height: cellDimension)
    }

    
    @IBAction func backBtnPressed(_ sender: Any) {
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

    // 아바타 픽업시 storage 방식으로 저장

}
