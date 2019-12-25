//
//  CalendarViewController.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 12/8/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    private var eventListView: EventListContainer = EventListContainer()
    private var eventCalendarView: EventCalendarContainer = EventCalendarContainer()
    
    private var calendarViewHidden = true

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var swapButton: UIBarButtonItem!
    
    private var events: [Event] = []
    private var states: [String: State] = [:]
    private var popoverVC: StatesPopoverViewController? = nil
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static let calendarNotification = Notification.Name("calendarNotification")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.states = self.appDelegate.states
        self.events = self.appDelegate.events
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        popoverVC = storyboard.instantiateViewController(withIdentifier: "StatesPopoverViewController") as! StatesPopoverViewController
        popoverVC!.modalPresentationStyle = .popover
        popoverVC!.addCalendarObserver()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onStatesConfigNotification(notification:)), name: StatesPopoverViewController.statesNotification, object: nil)
        
        initUI()
        
        NotificationCenter.default.post(name: CalendarViewController.calendarNotification, object: nil, userInfo:["states": self.states, "events": self.events.filter({ self.states[$0.state]!.displayState })])
    }
    
    private func initUI() {
        self.view.addSubview(eventListView)
        self.view.addSubview(eventCalendarView)
        
        self.eventListView.translatesAutoresizingMaskIntoConstraints = false
        self.eventCalendarView.translatesAutoresizingMaskIntoConstraints = false
        
        self.eventListView.isHidden = true
        self.eventCalendarView.isHidden = false
        
        let date: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateString = ("\(dateFormatter.string(from: date))")
        dateLabel.text = dateString
        
        setConstraints()
    }
    
    private func setConstraints() {
        self.eventListView.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor, constant: 0).isActive = true
        self.eventListView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.eventListView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        self.eventListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        self.eventCalendarView.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor, constant: 0).isActive = true
        self.eventCalendarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.eventCalendarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        self.eventCalendarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
    }
    
    // MARK: Notification Handlers
    
    @objc func onStatesConfigNotification(notification:Notification)
    {
        self.states = notification.userInfo?["states"] as! [String: State]
        NotificationCenter.default.post(name: CalendarViewController.calendarNotification, object: nil, userInfo:["states": self.states, "events": self.events.filter({ self.states[$0.state]!.displayState })])
    }
    
    @IBAction func swapViewAction(_ sender: UIBarButtonItem) {
        self.eventCalendarView.isHidden = !self.eventCalendarView.isHidden
        self.eventListView.isHidden = !self.eventListView.isHidden
        self.eventListView.dismissKeyboard()
        if self.eventCalendarView.isHidden {
            self.swapButton.image = UIImage(systemName: "calendar.circle")
        } else {
            self.swapButton.image = UIImage(systemName: "line.horizontal.3")
        }
    }
    
    @IBAction func displayConfigPopover(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: CalendarViewController.calendarNotification, object: nil, userInfo:["states": self.states, "events": self.events.filter({ self.states[$0.state]!.displayState })])
        let popover: UIPopoverPresentationController = self.popoverVC!.popoverPresentationController!
        popover.barButtonItem = sender
        present(self.popoverVC!, animated: true, completion:nil)
    }
}
