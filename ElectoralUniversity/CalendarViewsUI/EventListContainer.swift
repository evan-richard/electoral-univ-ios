//
//  EventListContainer.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 12/8/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class EventListContainer: UIView {
    
    private var searchBar: UISearchBar = UISearchBar()
    private var scrollView: UIScrollView = UIScrollView()
    private var nextEvent: EventListItemView = EventListItemView()
    
    private let SEARCH_BAR_HEIGHT: CGFloat = 60.0
    private var events: [Event] = []
    private var states: [String: State] = [:]
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onEventsNotification(notification:)), name: AppDelegate.fetchCompleteNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initUI() {
        self.addSubview(searchBar)
        self.addSubview(scrollView)
        self.scrollView.addSubview(nextEvent)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        nextEvent.translatesAutoresizingMaskIntoConstraints = false
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.addGestureRecognizer(tap)
        
        self.scrollView.backgroundColor = UIColor.systemBackground
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = nextEvent.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        nextEvent.addSubview(blurEffectView)
        nextEvent.sendSubviewToBack(blurEffectView)
        
        setConstraints()
    }
    
    private func setConstraints() {
        self.searchBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        self.searchBar.heightAnchor.constraint(equalToConstant: SEARCH_BAR_HEIGHT).isActive = true
        
        self.scrollView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 0).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        self.nextEvent.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 0).isActive = true
        self.nextEvent.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 0).isActive = true
        self.nextEvent.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor, constant: 0).isActive = true
    }
    
    @objc
    private func onEventsNotification(notification:Notification) {
        self.events = notification.userInfo?["events"] as! [Event]
        self.states = notification.userInfo?["states"] as! [String: State]
        self.events.sort(by: {
            $0.dateStr < $1.dateStr
        })
        self.events = self.events.filter({
            $0.state == "maryland"
        })
        addEvents()
    }
    
    private func makeEventCard(currEvent: Event, prevEvent: EventListItemView, lastEvent: Bool) -> EventListItemView {
        let event: EventListItemView = EventListItemView()
        self.scrollView.addSubview(event)
        event.translatesAutoresizingMaskIntoConstraints = false
        
        event.topAnchor.constraint(equalTo: prevEvent.bottomAnchor, constant: 0).isActive = true
        event.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: 0).isActive = true
        event.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor, constant: 0).isActive = true
        
        if lastEvent {
            event.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: 0).isActive = true
        }
        
        event.dateLabel.text = currEvent.dateStr
        event.eventLabel.text = currEvent.type
        event.politicalPartyLabel.text = currEvent.party
        event.stateNameLabel.text = self.states[currEvent.state]?.name
        
        return event
    }
    
    private func addEvents() {
        if (self.events.count > 1) {
            self.nextEvent.dateLabel.text = self.events[0].dateStr
            self.nextEvent.eventLabel.text = self.events[0].type
            self.nextEvent.politicalPartyLabel.text = self.events[0].party
            self.nextEvent.stateNameLabel.text = self.states[self.events[0].state]?.name
            var prevEvent = self.nextEvent
            for i in 1..<self.events.count {
                let currEvent = self.events[i]
                prevEvent = makeEventCard(currEvent: currEvent, prevEvent: prevEvent, lastEvent: (i == self.events.count - 1))
            }
        } else if (self.events.count == 1) {
            
        } else {
            
        }
    }
    
    @objc
    private func dismissKeyboard() {
        self.searchBar.endEditing(true)
    }

}
