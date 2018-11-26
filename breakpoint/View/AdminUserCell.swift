//
//  AdminUserCell.swift
//  breakpoint
//
//  Created by 김영석 on 13/11/2018.
//  Copyright © 2018 Caleb Stultz. All rights reserved.
//

import UIKit

class AdminUserCell: UITableViewCell {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userEmailLbl: UILabel!
    @IBOutlet weak var userSenderIDLbl: UILabel!
    
    func configureCell(profileImage: UIImage, email: String, SenderID: String) {
        self.userProfileImage.image = profileImage
        self.userEmailLbl.text = email
        self.userSenderIDLbl.text = SenderID
    }
}
