//
//  FeedViewController.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 10/4/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit
import Firebase
import ReadabilityKit

typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void

final class Animator {
    private var hasAnimatedAllCells = false
    private let animation: Animation

    init(animation: @escaping Animation) {
        self.animation = animation
    }

    func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        guard !hasAnimatedAllCells else {
            return
        }

        animation(cell, indexPath, tableView)

        hasAnimatedAllCells = cell == tableView.visibleCells.last
    }
}

enum AnimationFactory {

    static func makeFadeAnimation(duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, _ in
            cell.alpha = 0

            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                animations: {
                    cell.alpha = 1
            })
        }
    }
    
    static func makeMoveUpWithBounce(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)

            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.1,
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
}

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    static let tweetNotification = Notification.Name("tweetNotification")
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var socialLabel: UILabel!
    @IBOutlet weak var socialLabelConstraint: NSLayoutConstraint!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var tweets: [Tweet] = []
    private var newTweets: [Tweet] = []
    
    private var animateCells = true
    private var refreshing = false
    private var endOfNewTweets = false
    private var dispatchGroup: DispatchGroup = DispatchGroup()
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: "FeedTableViewCell")
        
        self.socialLabelConstraint.constant = -130
        self.activityIndicator.startAnimating()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTweetNotification(notification:)), name: FeedViewController.tweetNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDownloadNotification(notification:)), name: AppDelegate.downloadNotification, object: nil)
    }
    
    // MARK: Notification Handlers
    
    @objc func onTweetNotification(notification:Notification)
    {
        self.tweets = notification.userInfo?["tweets"] as! [Tweet]
    }
    
    @objc func onDownloadNotification(notification:Notification)
    {
        self.socialLabelConstraint.constant = 20
        UIView.animate(withDuration: 0.9) {
            self.view.layoutIfNeeded()
        }
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.tableView.reloadData()
        self.tableView.isHidden = false
    }
    
    // MARK: TableView Handlers
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell", for: indexPath) as! FeedTableViewCell
        
        let tweet = self.tweets[indexPath.row]
        let candidate = appDelegate.candidates[tweet.authorId]!
        let url = URL(string: candidate.profileImg)!
        
        AppDelegate.downloadImage(url: url, completion: { (profileImage: UIImage?, error: Error?) -> Void in
            if let _ = error {
                print("Image should be defaulted here.")
            } else {
                cell.profileImageView.layer.masksToBounds = true
                cell.profileImageView.layer.cornerRadius = 15
                cell.profileImageView.image = profileImage
            }
        })
        
        if ((tweet.retweet != nil) && (tweet.retweet!.count > 0)) {
            cell.tweetBox.layer.borderWidth = 1
            cell.tweetLabel.textContainerInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
            
            cell.retweet_name_label.text = tweet.retweet!["author_name"] ?? ""
            cell.retweet_screen_name_label.text = "@" + (tweet.retweet!["author_screen_name"] ?? "")
            
            cell.retweet_constraint?.isActive = true
            cell.non_retweet_constraint?.isActive = false
        } else {
            cell.tweetBox.layer.borderWidth = 0
            cell.tweetLabel.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            cell.retweet_name_label.text = ""
            cell.retweet_screen_name_label.text = ""
            
            cell.retweet_constraint?.isActive = false
            cell.non_retweet_constraint?.isActive = true
        }
        
        cell.tweetLabel.text = tweet.text
        cell.screenNameLabel.text = "@" + candidate.screenName
        cell.nameLabel.text = candidate.name
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let timestampString = formatter.string(from: tweet.timestamp)
        formatter.dateFormat = "• MMM dd, yyyy"
        let dateString = formatter.string(from: tweet.timestamp)
        cell.timeLabel.text = timestampString
        cell.dateLabel.text = dateString
        
//        if (tweet.media.count > 0) {
//            let articleUrl = URL(string: tweet.media[0]["url"]!)!
//            Readability.parse(url: articleUrl, completion: { data in
//                let title = data?.title
//                let description = data?.description
//                let keywords = data?.keywords
//                let imageUrl = data?.topImage
//                let videoUrl = data?.topVideo
//                if (imageUrl != nil) {
//                    AppDelegate.downloadImage(url: URL(string: imageUrl!)!, completion: { (previewImage: UIImage?, error: Error?) -> Void in
//                        if let _ = error {
//                            print("Image should be defaulted here.")
//                        } else {
//                            let previewImageView: UIImageView = UIImageView.init(image: previewImage)
//                            previewImageView.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
//                            previewImageView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 0).isActive = true
//                            previewImageView.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: 0).isActive = true
//                            cell.addSubview(previewImageView)
//                        }
//                    })
//                }
//            })
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.animateCells {
            let animation = AnimationFactory.makeMoveUpWithBounce(rowHeight: cell.frame.height, duration: 0.7, delayFactor: 0.05)
            let animator = Animator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
        }
    }
    
    @IBAction func scrollToTop(_ sender: Any) {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.animateCells = false
        let nearBottom = (3*scrollView.contentSize.height)/4
        if (scrollView.contentOffset.y > nearBottom) && (!self.refreshing) && (!self.endOfNewTweets) {
            self.refreshing = true
            
            self.dispatchGroup.enter()
            downloadOlderTweets()
            
            self.dispatchGroup.notify(queue: .main) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.refreshing = false
                }
                self.tableView.beginUpdates()
                for tweet in self.newTweets {
                    self.tweets.append(tweet)
                    self.tableView.insertRows(at: [(NSIndexPath(item: self.tweets.count-1, section: 0) as IndexPath)], with: .automatic)
                }
                self.tableView.endUpdates()
                self.newTweets = []
            }
        }
    }
    
    func downloadOlderTweets() {
        let lastTimestamp = tweets[tweets.count - 1].timestamp
        AppDelegate.db.collection("tweets").order(by: "timestamp", descending: true).whereField("timestamp", isLessThan: Timestamp(date: lastTimestamp)).limit(to: 50).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let tweet: Tweet = Tweet(dictionary: document.data()) {
                        self.newTweets.append(tweet)
                    }
                }
                if self.newTweets.count == 0 {
                    self.endOfNewTweets = true
                }
            }
            self.dispatchGroup.leave()
        }
    }
    
}

