//
//  EventListItemView.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 12/8/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class EventListItemView: UITableViewCell {
    
    var dateLabel: UILabel = UILabel()
    var eventLabel: UILabel = UILabel()
    var politicalPartyLabel: UILabel = UILabel()
    var stateNameLabel: UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.addSubview(dateLabel)
        self.addSubview(eventLabel)
        self.addSubview(politicalPartyLabel)
        self.addSubview(stateNameLabel)
        
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.eventLabel.translatesAutoresizingMaskIntoConstraints = false
        self.politicalPartyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.stateNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initUI() {
        dateLabel.textColor = UIColor.label
        eventLabel.textColor = UIColor.secondaryLabel
        politicalPartyLabel.textColor = UIColor.label
        stateNameLabel.textColor = UIColor.secondaryLabel
        
        dateLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        eventLabel.font = UIFont.systemFont(ofSize: 18)
        politicalPartyLabel.font = UIFont.systemFont(ofSize: 16)
        stateNameLabel.font = UIFont.systemFont(ofSize: 18)
        
        setConstraints()
    }
    
    private func setConstraints() {
        self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
        self.dateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).isActive = true
        self.dateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        
        self.eventLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        self.eventLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        self.eventLabel.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 30).isActive = true
        
        self.politicalPartyLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        self.politicalPartyLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        self.politicalPartyLabel.topAnchor.constraint(equalTo: self.eventLabel.bottomAnchor, constant: 16).isActive = true
        self.politicalPartyLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30).isActive = true
        
        self.stateNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true
        self.stateNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12).isActive = true
        self.stateNameLabel.leadingAnchor.constraint(equalTo: self.dateLabel.trailingAnchor, constant: 20).isActive = true
    }

}
