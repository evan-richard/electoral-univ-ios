//
//  CandidateViewCell.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 10/21/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class CandidateViewCell: UICollectionViewCell {

    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var partyLabel: UILabel!
    @IBOutlet weak var candidateImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = containerView.bounds
        containerView.addSubview(blurView)
        containerView.sendSubviewToBack(blurView)
    }
}
