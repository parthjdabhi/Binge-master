//
//  MyGroupTableViewCell.swift
//  What2Watch
//
//  Created by iParth on 10/25/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class MyGroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var lblPeopleCount: UILabel!
    @IBOutlet weak var imgGroup: UIImageView!
    @IBOutlet weak var cvPeople: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

extension MyGroupTableViewCell {

    
    func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
        
        cvPeople.delegate = dataSourceDelegate
        cvPeople.dataSource = dataSourceDelegate
        cvPeople.tag = row
        cvPeople.setContentOffset(cvPeople.contentOffset, animated:false) // Stops collection view if it was scrolling.
        cvPeople.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set {
            cvPeople.contentOffset.x = newValue
        }
        
        get {
            return cvPeople.contentOffset.x
        }
    }
}
