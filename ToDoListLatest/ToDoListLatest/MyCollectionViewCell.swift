//
//  MyCollectionViewCell.swift
//  ToDoListLatest
//
//  Created by Jh Xing on 22/04/2021.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {

    @IBOutlet var collectionItemLabel: UILabel!
    @IBOutlet var collectionDateLabel: UILabel!

    static let identifier = "MyCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10.0
    }
    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }
}
