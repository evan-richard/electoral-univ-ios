//
//  DateCell.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 12/21/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import Foundation
import JTAppleCalendar
import UIKit

class DateCell: JTACDayCell {
    var dateLabel: UILabel = UILabel()
    var borderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.secondarySystemBackground
        
        addSubview(dateLabel)
        addSubview(borderView)
        
        borderView.backgroundColor = UIColor.secondaryLabel
        borderView.isHidden = false
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 18)
        dateLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        borderView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
