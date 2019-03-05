//
//  DetailGroupFeedCell.swift
//  breakpoint
//
//  Created by 김영석 on 17/02/2019.
//  Copyright © 2019 Caleb Stultz. All rights reserved.
//

import UIKit

class DetailGroupFeedCell: UITableViewCell {
    

    @IBOutlet weak var detailGroupProfileImage: UIImageView!
    @IBOutlet weak var detailGroupEmailLbl: UILabel!
    @IBOutlet weak var detailGroupTitleLbl: UILabel!
    @IBOutlet weak var detailGroupContentLbl: UILabel!
    
    func configureCell(profileImage: UIImage, email: String, title: String,content: String) {
        self.detailGroupProfileImage.image = profileImage
        self.detailGroupEmailLbl.text = email
        self.detailGroupTitleLbl.text = title
        self.detailGroupContentLbl.text = content
        
    }
    
}


/*
 
 @IBOutlet weak var detailProfileImage: UIImageView!
 @IBOutlet weak var detailEmailLbl: UILabel!
 @IBOutlet weak var detailContentLbl: UILabel!
 */
