//
//  ResultsViewContainer.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 11/30/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import Foundation
import UIKit

class ResultsViewContainer: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var resultsLabel: UILabel = UILabel()
    private var dividerView: UIView = UIView()
    
    private var matches: [(key: String, value: Int)] = []
    private var collectionView: UICollectionView? = nil
    
    init(candidateMatches: [(key: String, value: Int)]) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.matches = candidateMatches
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initUI() {
        self.addSubview(resultsLabel)
        self.addSubview(dividerView)
        
        resultsLabel.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        
        setConstraints()
        initCollectionView()
    }
    
    private func setConstraints() {
        self.resultsLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.resultsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        self.resultsLabel.textColor = UIColor.white
        self.resultsLabel.textAlignment = .left
        self.resultsLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        self.resultsLabel.numberOfLines = 1
        self.resultsLabel.text = "Results"
        
        self.dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.dividerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        self.dividerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        self.dividerView.topAnchor.constraint(equalTo: self.resultsLabel.bottomAnchor, constant: 4).isActive = true
        self.dividerView.backgroundColor = UIColor.lightGray
    }
    
    private func initCollectionView() {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.register(UINib(nibName: "ResultsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ResultsCollectionViewCell")
        
        self.addSubview(collectionView!)
        
        self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView?.topAnchor.constraint(equalTo: self.dividerView.topAnchor, constant: 20).isActive = true
        self.collectionView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8).isActive = true
        self.collectionView?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2).isActive = true
        self.collectionView?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 2).isActive = true
        
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
    }
    
    // MARK: Collection View Handlers
            
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        appDelegate.candidates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 24

        return CGSize(width: width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultsCollectionViewCell", for: indexPath) as! ResultsCollectionViewCell
        
        let candidateMatch = self.matches[indexPath.row]
        let candidate = appDelegate.candidates[candidateMatch.key]
        let matchPercent = CGFloat(100 * candidateMatch.value / appDelegate.issues.count)
        let barWidth = cell.progressBar.frame.size.width
        let progress: CGFloat = barWidth - ((matchPercent/100) * barWidth)
        
        cell.candidateNameLabel.text = candidate?.name
        cell.matchesLabel.text = String(candidateMatch.value) + (candidateMatch.value > 1 ? " Matches" : " Match")
        cell.progressConstraint.constant = progress
//        cell.progressBar.layer.cornerRadius = 10
        cell.progressBar.layer.borderWidth = 1
        cell.progressBar.layer.borderColor = UIColor.white.cgColor
        
        let url = URL(string: candidate?.profileImg ?? "")!
        AppDelegate.downloadImage(url: url, completion: { (profileImage: UIImage?, error: Error?) -> Void in
            if let _ = error {
                print("Image should be defaulted here.")
            } else {
                cell.candidateImageView.layer.masksToBounds = true
                cell.candidateImageView.layer.cornerRadius = 15
                cell.candidateImageView.image = profileImage
            }
        })
        
        return cell
    }
}
