//
//  DetailFeedCell.swift
//  breakpoint
//
//  Created by 김영석 on 15/02/2019.
//  Copyright © 2019 Caleb Stultz. All rights reserved.
//

import UIKit

class DetailFeedCell: UITableViewCell {
    
    @IBOutlet weak var detailProfileImage: UIImageView!
    @IBOutlet weak var detailEmailLbl: UILabel!
    @IBOutlet weak var detailContentLbl: UILabel!
    
    
    func configureCell(profileImage: UIImage, email: String, content: String) {
        self.detailProfileImage.image = profileImage
        self.detailEmailLbl.text = email
        self.detailContentLbl.text = content
    }
}
