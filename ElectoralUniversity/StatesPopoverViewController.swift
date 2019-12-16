//
//  StatesPopoverViewController.swift
//  ElectoralUniversity
//
//  Created by Evan Richard on 12/15/19.
//  Copyright © 2019 EvanRichard. All rights reserved.
//

import UIKit

class StatesPopoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    static let statesNotification = Notification.Name("statesNotification")
    
    private var statesList: [State] = []
    private var allSelected = true
    
    @IBOutlet weak var selectAllCheckboxView: UIView!
    @IBOutlet weak var selectAllCheckImageView: UIImageView!
    @IBOutlet weak var selectAllContentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.selectAllCheckImageView.isHidden = !allSelected
        self.selectAllCheckboxView.layer.cornerRadius = 5
        self.selectAllCheckboxView.layer.borderWidth = 1
        self.selectAllCheckboxView.layer.borderColor = UIColor.secondaryLabel.cgColor
        
        let selectView: UIView = UIView(frame: self.selectAllContentView.frame)
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectAllStates(_:)))
        tap.numberOfTapsRequired = 1
        selectView.addGestureRecognizer(tap)
        selectView.backgroundColor = UIColor.clear
        self.selectAllContentView.addSubview(selectView)
        self.selectAllContentView.bringSubviewToFront(selectView)
    }
    
    func addCalendarObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onCalendarNotification(notification:)), name: CalendarViewController.calendarNotification, object: nil)
    }
    
    @objc func selectAllStates(_ sender: UITapGestureRecognizer) {
        for index in 0...self.statesList.count - 1 {
            self.statesList[index].displayState = !self.allSelected
        }
        self.tableView.reloadData()
        self.allSelected = !self.allSelected
        self.selectAllCheckImageView.isHidden = !allSelected
    }
    
    // MARK: Notification Handlers
    
    @objc func onCalendarNotification(notification:Notification)
    {
        let states = notification.userInfo?["states"] as! [String: State]
        self.statesList = Array(states.values).sorted(by: {
            $0.name < $1.name
        })
    }
    
    @IBAction func confirmSelections(_ sender: UIButton) {
        var stateDict: [String: State] = [:]
        for state in self.statesList {
            stateDict[state.identifier] = state
        }
        NotificationCenter.default.post(name: StatesPopoverViewController.statesNotification, object: nil, userInfo:["states": stateDict])
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.statesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateConfigCell", for: indexPath) as! StateTableViewCell
        
        cell.stateLabel.text = self.statesList[indexPath.row].name
        cell.checkmarkImageView.isHidden = !self.statesList[indexPath.row].displayState
        cell.checkboxView.layer.cornerRadius = 5
        cell.checkboxView.layer.borderWidth = 1
        cell.checkboxView.layer.borderColor = UIColor.secondaryLabel.cgColor
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statesList[indexPath.row].displayState = !self.statesList[indexPath.row].displayState
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
