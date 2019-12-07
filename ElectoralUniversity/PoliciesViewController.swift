//
//  QuizViewController.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 10/4/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class PoliciesViewController: UIViewController {
    
    static let issueNotification = Notification.Name("issueNotification")
    
    @IBOutlet weak var quizNameLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var startOverButton: UIButton!
    @IBOutlet weak var policyViewContent: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var quizView: QuizViewContainer? = nil
    private var resultsView: ResultsViewContainer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onMatchesNotification(notification:)), name: QuizViewContainer.matchesNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func initUI() {
        self.policyViewContent.layer.masksToBounds = true
        self.policyViewContent.layer.cornerRadius = 15
        self.prevButton.isEnabled = false
        self.prevButton.alpha = 0
        
        self.quizView = QuizViewContainer()
        self.policyViewContent.addSubview(quizView!)
        self.quizView?.translatesAutoresizingMaskIntoConstraints = false
        self.quizView?.topAnchor.constraint(equalTo: self.policyViewContent.topAnchor, constant: 60).isActive = true
        self.quizView?.leadingAnchor.constraint(equalTo: self.policyViewContent.leadingAnchor, constant: 0).isActive = true
        self.quizView?.trailingAnchor.constraint(equalTo: self.policyViewContent.trailingAnchor, constant: 0).isActive = true
        self.quizView?.bottomAnchor.constraint(equalTo: self.policyViewContent.bottomAnchor, constant: -100).isActive = true
        self.quizView?.alpha = 0
        self.quizView?.isHidden = true
        
        self.quizNameLabel.alpha = 1
        self.startButton.layer.borderColor = UIColor.white.cgColor
        self.startButton.layer.borderWidth = 1
        self.startButton.layer.cornerRadius = 10
        self.startOverButton.layer.borderColor = UIColor.white.cgColor
        self.startOverButton.layer.borderWidth = 1
        self.startOverButton.layer.cornerRadius = 10
        self.startOverButton.isEnabled = false
        self.startOverButton.alpha = 0
        self.policyViewContent.bringSubviewToFront(prevButton)
        
        self.backgroundImageView.contentMode = .scaleAspectFill
        
        if self.traitCollection.userInterfaceStyle == .dark {
            self.backgroundImageView.image = UIImage(named: "background_dark.jpg")
        } else {
            self.backgroundImageView.image = UIImage(named: "background_light.jpg")
        }
    }
    
    @IBAction func startButtonTouchDown(_ sender: UIButton) {
        sender.layer.borderColor = UIColor.gray.cgColor
    }
    
    
    @IBAction func startQuiz(_ sender: UIButton) {
        sender.layer.borderColor = UIColor.white.cgColor
        
        self.quizView?.start()
        self.quizView?.isHidden = false
        self.prevButton.isEnabled = true
        
        sender.isEnabled = false
        
        UIView.animate(withDuration: 0.3, delay: 0.1, animations: { () -> Void in
            self.quizNameLabel.alpha = 0
            sender.alpha = 0
        }, completion: { (Bool) -> Void in
            UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
                self.quizView?.alpha = 1
                self.prevButton.alpha = 1
            })
        })
    }
    
    @IBAction func prevButtonAction(_ sender: UIButton) {
        if (self.quizView?.index ?? 0 > 0) {
            self.quizView?.prevQuizData()
        } else {
            resetQuiz()
        }
    }
    
    @IBAction func startOverTouchDown(_ sender: UIButton) {
        sender.layer.borderColor = UIColor.gray.cgColor
    }
    
    @IBAction func startOverButtonAction(_ sender: UIButton) {
        sender.layer.borderColor = UIColor.white.cgColor
        resetQuiz()
    }
    
    @IBAction func settingsButtonAction(_ sender: UIButton) {
            
    }
    
    private func resetQuiz() {
        self.startButton.isEnabled = true
        self.prevButton.isEnabled = false
        self.startOverButton.isEnabled = false
        self.quizView?.stop()
        UIView.animate(withDuration: 0.3, delay: 0.3, animations: { () -> Void in
            self.quizView?.alpha = 0
            self.resultsView?.alpha = 0
            self.prevButton.alpha = 0
            self.startOverButton.alpha = 0
        }, completion: { (Bool) -> Void in
            UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
                self.quizView?.isHidden = true
                self.quizNameLabel.alpha = 1
                self.startButton.alpha = 1
            })
        })
    }
    
    private func showResults(matches: [(key: String, value: Int)]) {
        self.resultsView = ResultsViewContainer(candidateMatches: matches)
        self.resultsView?.alpha = 0
        self.resultsView?.isHidden = true
        self.policyViewContent.addSubview(resultsView!)
        self.resultsView?.translatesAutoresizingMaskIntoConstraints = false
        self.resultsView?.topAnchor.constraint(equalTo: self.policyViewContent.topAnchor, constant: 40).isActive = true
        self.resultsView?.leadingAnchor.constraint(equalTo: self.policyViewContent.leadingAnchor, constant: 0).isActive = true
        self.resultsView?.trailingAnchor.constraint(equalTo: self.policyViewContent.trailingAnchor, constant: 0).isActive = true
        self.resultsView?.bottomAnchor.constraint(equalTo: self.policyViewContent.bottomAnchor, constant: -100).isActive = true
        
        self.prevButton.isEnabled = false
        
        UIView.animate(withDuration: 0.3, delay: 0.3, animations: { () -> Void in
            self.quizView?.alpha = 0
            self.prevButton.alpha = 0
        }, completion: { (Bool) -> Void in
            self.quizView?.isHidden = true
            self.resultsView?.isHidden = false
            UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
                self.resultsView?.alpha = 1
                self.startOverButton.alpha = 1
            })
        })
    }
    
    // MARK: Notification Handlers
    
    @objc func onMatchesNotification(notification:Notification)
    {
        let matches = notification.userInfo?["matches"] as! [(key: String, value: Int)]
        showResults(matches: matches)
        self.startOverButton.isEnabled = true
    }
}

