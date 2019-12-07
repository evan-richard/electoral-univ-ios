//
//  QuizViewContainer.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 11/23/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import Foundation
import UIKit

class QuizViewContainer: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var policyLabel: UILabel = UILabel()
    private var topicLabel: UILabel = UILabel()
    private var questionLabel: UILabel = UILabel()
    private var dividerView: UIView = UIView()
    
    private var collectionView: UICollectionView? = nil
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static let matchesNotification = Notification.Name("matchesNotification")
    
    var index: Int = 0
    var userResponses:[String:Int] = [:]
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initUI() {
        self.addSubview(policyLabel)
        self.addSubview(topicLabel)
        self.addSubview(questionLabel)
        self.addSubview(dividerView)
        
        policyLabel.translatesAutoresizingMaskIntoConstraints = false
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        
        setConstraints()
        initCollectionView()
    }
    
    private func setConstraints() {
        self.policyLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.policyLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.policyLabel.textColor = UIColor.white
        self.policyLabel.textAlignment = .center
        self.policyLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        self.policyLabel.adjustsFontForContentSizeCategory = true
        
        self.topicLabel.topAnchor.constraint(equalTo: self.policyLabel.bottomAnchor, constant: 18).isActive = true
        self.topicLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        self.topicLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        self.topicLabel.textColor = UIColor.lightText
        self.topicLabel.textAlignment = .center
        self.topicLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        self.topicLabel.adjustsFontForContentSizeCategory = true
        self.topicLabel.numberOfLines = 2
        
        self.questionLabel.topAnchor.constraint(equalTo: self.topicLabel.bottomAnchor, constant: 25).isActive = true
        self.questionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        self.questionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        self.questionLabel.textColor = UIColor.white
        self.questionLabel.textAlignment = .left
        self.questionLabel.font = UIFont.systemFont(ofSize: 20)
        self.questionLabel.numberOfLines = 6
        
        self.dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.dividerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        self.dividerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        self.dividerView.topAnchor.constraint(equalTo: self.policyLabel.bottomAnchor, constant: 8).isActive = true
        self.dividerView.backgroundColor = UIColor.lightGray
    }
    
    private func initCollectionView() {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.register(UINib(nibName: "QuizCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "QuizCollectionViewCell")
        
        self.addSubview(collectionView!)
        
        self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView?.topAnchor.constraint(equalTo: self.questionLabel.bottomAnchor, constant: 15).isActive = true
        self.collectionView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        self.collectionView?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2).isActive = true
        self.collectionView?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -2).isActive = true
        
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
    }
    
    func start() {
        self.index = 0
        self.collectionView?.reloadData()
        
        self.policyLabel.text = appDelegate.issues[self.index].policy
        self.topicLabel.text = appDelegate.issues[self.index].topic
        self.questionLabel.text = appDelegate.issues[self.index].question
    }
    
    func stop() {
        self.index = 0
    }
    
    private func animateQuizLabels() {
        UIView.animate(withDuration: 0.3, delay: 0.3, animations: { () -> Void in
            self.alpha = 0
        }, completion: { (Bool) -> Void in
            self.policyLabel.text = self.appDelegate.issues[self.index].policy
            self.topicLabel.text = self.appDelegate.issues[self.index].topic
            self.questionLabel.text = self.appDelegate.issues[self.index].question
            self.collectionView?.reloadData()
            UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
                self.alpha = 1
            })
        })
    }
    
    private func nextQuizData() {
        if (self.index < appDelegate.issues.count - 1) {
            self.index = self.index + 1
            animateQuizLabels()
        }
    }
    
    func prevQuizData() {
        self.index = self.index - 1
        animateQuizLabels()
    }
    
    private func matchCandidates() -> [(key: String, value: Int)] {
        var matches: [String:Int] = [:]
        for (responseId, response) in userResponses {
            for (candidateId, candidate) in self.appDelegate.candidates {
                var count = matches[candidateId, default: 0]
                if (candidate.responses[responseId] == response) {
                    count = count + 1
                }
                matches[candidateId] = count
            }
        }
        return matches.sorted { $0.1 > $1.1 }
    }
    
    // MARK: Collection View Handlers
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        appDelegate.issues[self.index].stances.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuizCollectionViewCell", for: indexPath) as! QuizCollectionViewCell
        cell.responseLabel.text = appDelegate.issues[self.index].stances[indexPath.row].text
        cell.checkboxView.layer.cornerRadius = 5
        cell.checkboxView.layer.borderWidth = 2
        cell.checkboxView.layer.borderColor = UIColor.white.cgColor
        cell.checkmarkView.alpha = 0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 24

        return CGSize(width: width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? QuizCollectionViewCell {
            cell.checkmarkView.alpha = 1
            let topicId = self.appDelegate.issues[self.index].id
            let response = self.appDelegate.issues[self.index].stances[indexPath.row].id
            self.userResponses[topicId] = response
            if (self.index < self.appDelegate.issues.count - 1) {
                nextQuizData()
                UIView.animate(withDuration: 0.3, delay: 0.3, animations: { () -> Void in
                    cell.leadingConstraint?.constant = -20
                    self.layoutIfNeeded()
                }, completion: { (Bool) -> Void in
                    cell.leadingConstraint?.constant = 20
                    self.layoutIfNeeded()
                })
            } else {
                let matches = matchCandidates()
                NotificationCenter.default.post(name: QuizViewContainer.matchesNotification, object: nil, userInfo: ["matches": matches])
            }
        }
    }
    
}
