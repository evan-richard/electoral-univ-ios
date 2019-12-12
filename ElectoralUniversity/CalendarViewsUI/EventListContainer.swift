//
//  EventListContainer.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 12/8/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class EventListContainer: UIView, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.filterStates.count > 0) {
            return self.events.filter({
                self.filterStates.contains($0.state)
            }).count
        } else {
            return self.events.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventListItemView", for: indexPath) as! EventListItemView
        let filteredEvents: [Event]
        if (self.filterStates.count > 0) {
            filteredEvents = self.events.filter({
                self.filterStates.contains($0.state)
            })
        } else {
            filteredEvents = self.events
        }
        let event = filteredEvents[indexPath.row]
        
        cell.dateLabel.text = event.dateStr
        cell.eventLabel.text = event.type
        cell.politicalPartyLabel.text = event.party
        cell.stateNameLabel.text = self.states[event.state]?.name
        
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor.secondarySystemBackground
        } else {
            cell.backgroundColor = UIColor.systemBackground
        }
        
        return cell
    }
    
    
    private var searchBar: UISearchBar = UISearchBar()
    private var tableView: UITableView = UITableView()
    
    private let SEARCH_BAR_HEIGHT: CGFloat = 60.0
    private var events: [Event] = []
    private var states: [String: State] = [:]
    private var filterStates: [String] = []
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EventListItemView.self, forCellReuseIdentifier: "EventListItemView")
        
        self.filterStates = ["maryland"]
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onEventsNotification(notification:)), name: AppDelegate.fetchCompleteNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initUI() {
        self.addSubview(searchBar)
        self.addSubview(tableView)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.addGestureRecognizer(tap)
        
        self.tableView.backgroundColor = UIColor.systemBackground
        
        setConstraints()
    }
    
    private func setConstraints() {
        self.searchBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        self.searchBar.heightAnchor.constraint(equalToConstant: SEARCH_BAR_HEIGHT).isActive = true
        
        self.tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 0).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
    @objc
    private func onEventsNotification(notification:Notification) {
        self.events = notification.userInfo?["events"] as! [Event]
        self.states = notification.userInfo?["states"] as! [String: State]
        self.events.sort(by: {
            $0.dateStr < $1.dateStr
        })
        addEvents(events: self.events.filter({
            $0.state == "maryland"
        }))
    }
    
    private func addEvents(events: [Event]) {
        if (events.count > 1) {
            self.tableView.reloadData()
        } else if (events.count == 1) {
            
        } else {
            
        }
    }
    
    func configureToggled(filterStates: [String]) {
        self.filterStates = filterStates
        if (self.filterStates.count > 0) {
            self.addEvents(events: self.events.filter({
                self.filterStates.contains($0.state)
            }))
        } else {
            self.addEvents(events: self.events)
        }
    }
    
    @objc
    func dismissKeyboard() {
        self.searchBar.endEditing(true)
    }

}
