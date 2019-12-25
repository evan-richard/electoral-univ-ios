//
//  EventCalendarContainer.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 12/11/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import Foundation
import UIKit
import JTAppleCalendar

class DayLabel: UILabel {
    init(text: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.text = text
        self.font = UIFont.systemFont(ofSize: 16)
        self.textColor = UIColor.secondaryLabel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class EventCalendarContainer: UIView, JTACMonthViewDataSource, JTACMonthViewDelegate {
    
    private var calendar = JTACMonthView()
    private var weekdayBar = UIStackView()
    
    private var eventsDict: [String: [Event]] = [:]
    private var states: [String: State] = [:]
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        calendar.ibCalendarDelegate = self
        calendar.ibCalendarDataSource = self
        calendar.register(DateCell.self, forCellWithReuseIdentifier: "dateCell")
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onEventsNotification(notification:)), name: CalendarViewController.calendarNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initUI() {
        addSubview(calendar)
        addSubview(weekdayBar)
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        weekdayBar.translatesAutoresizingMaskIntoConstraints = false
        
        calendar.backgroundColor = UIColor.secondarySystemBackground
        weekdayBar.backgroundColor = UIColor.systemBackground
        
        weekdayBar.distribution = UIStackView.Distribution.equalSpacing
        weekdayBar.axis = NSLayoutConstraint.Axis.horizontal
        
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.scrollToDate(Date())
        calendar.showsVerticalScrollIndicator = false
        
        weekdayBar.addArrangedSubview(DayLabel(text: "s"))
        weekdayBar.addArrangedSubview(DayLabel(text: "m"))
        weekdayBar.addArrangedSubview(DayLabel(text: "t"))
        weekdayBar.addArrangedSubview(DayLabel(text: "w"))
        weekdayBar.addArrangedSubview(DayLabel(text: "t"))
        weekdayBar.addArrangedSubview(DayLabel(text: "f"))
        weekdayBar.addArrangedSubview(DayLabel(text: "s"))
        
        setConstraints()
    }
    
    private func setConstraints() {
        weekdayBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 22).isActive = true
        weekdayBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24).isActive = true
        weekdayBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        
        calendar.topAnchor.constraint(equalTo: weekdayBar.bottomAnchor, constant: 0).isActive = true
        calendar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        calendar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        calendar.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
        calendar.minimumInteritemSpacing = 0
        calendar.minimumLineSpacing = 0
    }
    
    @objc
    private func onEventsNotification(notification:Notification) {
        eventsDict = [:]
        let events = notification.userInfo?["events"] as! [Event]
        for event in events {
            var dailyEvents: [Event] = []
            if let eventList = eventsDict[event.dateStr] {
                dailyEvents = eventList
            } else {
                dailyEvents.append(event)
            }
            eventsDict[event.dateStr] = dailyEvents
        }
        states = notification.userInfo?["states"] as! [String: State]
        addEvents()
    }
    
    private func addEvents() {
        calendar.reloadData()
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState, indexPath: indexPath)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2019 01 01")!
        let endDate = formatter.date(from: "2200 12 31")!
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
    
    private func configureCell(view: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text

        let areaOfCal = 7 * 6
        // Hide the bottom border on the last row being displayed
        if (indexPath.row > 0 && indexPath.row % areaOfCal >= areaOfCal - 7 && indexPath.row % areaOfCal < areaOfCal) {
            cell.borderView.isHidden = true
        } else {
            cell.borderView.isHidden = false
        }

        if (Calendar.current.isDateInToday(cellState.date)) {
            cell.backgroundColor = UIColor.tertiarySystemBackground
        } else {
            cell.backgroundColor = UIColor.secondarySystemBackground
        }

        handleCellTextColor(cell: cell, cellState: cellState)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let event = eventsDict[formatter.string(from: cellState.date)] {
            cell.dateLabel.textColor = UIColor.systemRed
        }
    }
        
    private func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.label
        } else {
            cell.dateLabel.textColor = UIColor.secondaryLabel
        }
    }
    
}
