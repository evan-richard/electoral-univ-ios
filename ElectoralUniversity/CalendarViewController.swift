//
//  CalendarViewController.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 12/8/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {
    
    private var eventListView: EventListContainer = EventListContainer()
    private var eventCalendarView: EventCalendarContainer = EventCalendarContainer()
    
    private var calendarViewHidden = true

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    private func initUI() {
        self.view.addSubview(eventListView)
        self.view.addSubview(eventCalendarView)
        
        self.eventListView.translatesAutoresizingMaskIntoConstraints = false
        self.eventCalendarView.translatesAutoresizingMaskIntoConstraints = false
        
        self.eventListView.isHidden = false
        self.eventCalendarView.isHidden = true
        
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
    
    @IBAction func swapViewAction(_ sender: UIBarButtonItem) {
        self.eventCalendarView.isHidden = !self.eventCalendarView.isHidden
        self.eventListView.isHidden = !self.eventListView.isHidden
    }
    
}
