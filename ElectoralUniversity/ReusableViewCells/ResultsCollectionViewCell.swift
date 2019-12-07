//
//  ResultsCollectionViewCell.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 11/30/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class ResultsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var progressConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var matchesLabel: UILabel!
    @IBOutlet weak var candidateNameLabel: UILabel!
    @IBOutlet weak var candidateImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
