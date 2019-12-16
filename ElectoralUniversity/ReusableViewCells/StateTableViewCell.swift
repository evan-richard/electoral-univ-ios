//
//  StateTableViewCell.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 12/15/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class StateTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var checkboxView: UIView!
    @IBOutlet weak var stateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
