//
//  EventListContainer.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 12/8/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class EventListContainer: UIView, UITableViewDataSource, UITableViewDelegate {
    
    private var searchBar: UISearchBar = UISearchBar()
    private var tableView: UITableView = UITableView()
    
    private let SEARCH_BAR_HEIGHT: CGFloat = 60.0
    
    private var events: [Event] = []
    private var states: [String: State] = [:]
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EventListItemView.self, forCellReuseIdentifier: "EventListItemView")
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onEventsNotification(notification:)), name: CalendarViewController.calendarNotification, object: nil)
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
        addEvents()
    }
    
    private func addEvents() {
        if (self.events.count > 1) {
            self.tableView.reloadData()
        } else if (self.events.count == 1) {
            
        } else {
            
        }
    }
    
    @objc
    func dismissKeyboard() {
        self.searchBar.endEditing(true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventListItemView", for: indexPath) as! EventListItemView
        let event = self.events[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateObj = dateFormatter.date(from: event.dateStr)
        dateFormatter.dateFormat = "EEE, dd MMM yyyy"
        let formattedDateStr = ("\(dateFormatter.string(from: dateObj!))")
        
        cell.dateLabel.text = formattedDateStr
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
}
