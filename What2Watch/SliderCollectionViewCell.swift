//
//  SliderCollectionViewCell.swift
//  What2Watch
//
//  Created by iParth on 8/16/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class SliderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    static let identifier = "SliderCollectionViewCell"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        self.image.layer.cornerRadius = max(self.image.frame.size.width, self.image.frame.size.height) / 2
//        self.image.layer.borderWidth = 10
//        self.image.layer.borderColor = UIColor(red: 110.0/255.0, green: 80.0/255.0, blue: 140.0/255.0, alpha: 1.0).CGColor
    }
}