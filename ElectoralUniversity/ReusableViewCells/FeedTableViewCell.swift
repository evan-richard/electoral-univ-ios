//
//  FeedTableViewCell.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 10/19/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    var nameLabel: UILabel = UILabel()
    var screenNameLabel: UILabel = UILabel()
    var tweetLabel: UITextView = UITextView()
    var profileImageView: UIImageView = UIImageView()
    var timeLabel: UILabel = UILabel()
    var dateLabel: UILabel = UILabel()
    var retweet_name_label: UILabel = UILabel()
    var retweet_screen_name_label: UILabel = UILabel()
    var tweetBox: UIView = UIView()
    
    var non_retweet_constraint: NSLayoutConstraint? = nil
    var retweet_constraint: NSLayoutConstraint? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.addSubview(nameLabel)
        self.addSubview(screenNameLabel)
        self.addSubview(profileImageView)
        self.addSubview(timeLabel)
        self.addSubview(dateLabel)
        self.tweetBox.addSubview(retweet_name_label)
        self.tweetBox.addSubview(retweet_screen_name_label)
        self.tweetBox.addSubview(tweetLabel)
        self.addSubview(tweetBox)
        
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.screenNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.tweetLabel.translatesAutoresizingMaskIntoConstraints = false
        self.profileImageView.translatesAutoresizingMaskIntoConstraints = false
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.retweet_name_label.translatesAutoresizingMaskIntoConstraints = false
        self.retweet_screen_name_label.translatesAutoresizingMaskIntoConstraints = false
        self.tweetBox.translatesAutoresizingMaskIntoConstraints = false
        
        setConstraints()
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    private func setConstraints() {
        self.profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        self.profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        self.profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.nameLabel.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 12).isActive = true
        self.nameLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
       
        self.screenNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        self.screenNameLabel.leadingAnchor.constraint(equalTo: self.nameLabel.trailingAnchor, constant: 6).isActive = true
        
        self.tweetBox.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 8).isActive = true
        self.tweetBox.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 12).isActive = true
        self.tweetBox.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12).isActive = true
        
        self.timeLabel.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 12).isActive = true
        self.timeLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        self.timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        self.timeLabel.topAnchor.constraint(equalTo: self.tweetBox.bottomAnchor, constant: 12).isActive = true
        
        self.dateLabel.leadingAnchor.constraint(equalTo: self.timeLabel.trailingAnchor, constant: 6).isActive = true
        self.dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        
        self.retweet_name_label.topAnchor.constraint(equalTo: self.tweetBox.topAnchor, constant: 10).isActive = true
        self.retweet_name_label.leadingAnchor.constraint(equalTo: self.tweetBox.leadingAnchor, constant: 14).isActive = true
        self.retweet_name_label.trailingAnchor.constraint(equalTo: self.tweetBox.trailingAnchor, constant: -14).isActive = true
        
        self.retweet_screen_name_label.topAnchor.constraint(equalTo: self.retweet_name_label.bottomAnchor, constant: 2).isActive = true
        self.retweet_screen_name_label.leadingAnchor.constraint(equalTo: self.tweetBox.leadingAnchor, constant: 14).isActive = true
        self.retweet_screen_name_label.trailingAnchor.constraint(equalTo: self.tweetBox.trailingAnchor, constant: -14).isActive = true
        
        self.tweetLabel.leadingAnchor.constraint(equalTo: self.tweetBox.leadingAnchor, constant: 0).isActive = true
        self.tweetLabel.trailingAnchor.constraint(equalTo: self.tweetBox.trailingAnchor, constant: 0).isActive = true
        self.tweetLabel.bottomAnchor.constraint(equalTo: self.tweetBox.bottomAnchor, constant: 0).isActive = true
        
        self.retweet_constraint = self.tweetLabel.topAnchor.constraint(equalTo: self.retweet_screen_name_label.bottomAnchor, constant: 8)
        self.non_retweet_constraint = self.tweetLabel.topAnchor.constraint(equalTo: self.tweetBox.topAnchor, constant: 0)
    }
    
    private func setUI() {
        self.tweetBox.backgroundColor = .clear
        self.tweetBox.layer.borderColor = UIColor.lightGray.cgColor
        self.tweetBox.layer.cornerRadius = 5
        
        self.nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        self.screenNameLabel.font = UIFont.systemFont(ofSize: 13)
        self.screenNameLabel.textColor = UIColor.secondaryLabel
        
        self.tweetLabel.font = UIFont.systemFont(ofSize: 15)
        self.tweetLabel.isScrollEnabled = false
        self.tweetLabel.isEditable = false
        self.tweetLabel.isSelectable = false
        
        self.timeLabel.font = UIFont.systemFont(ofSize: 14)
        self.timeLabel.textColor = UIColor.secondaryLabel
        
        self.dateLabel.font = UIFont.systemFont(ofSize: 14)
        self.dateLabel.textColor = UIColor.secondaryLabel
        
        self.retweet_name_label.font = UIFont.systemFont(ofSize: 15)
        self.retweet_screen_name_label.font = UIFont.systemFont(ofSize: 13)
        self.retweet_screen_name_label.textColor = UIColor.secondaryLabel
    }
        

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
