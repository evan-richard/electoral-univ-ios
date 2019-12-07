//
//  QuizCollectionViewCell.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 11/9/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class QuizCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var checkboxView: UIView!
    @IBOutlet weak var checkmarkView: UIImageView!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
