//
//  AvatarCell.swift
//  breakpoint
//
//  Created by 김영석 on 2018. 10. 13..
//  Copyright © 2018년 Caleb Stultz. All rights reserved.
//

import UIKit

class AvatarCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    
    func configureCell(index: Int){
        avatarImg.image = UIImage(named: "dark\(index)")
        self.layer.backgroundColor = UIColor.lightGray.cgColor
    }
    
    func setUpView() {
        self.layer.backgroundColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
    }
}
