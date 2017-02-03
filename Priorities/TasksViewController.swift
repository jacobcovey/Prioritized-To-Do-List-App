//
//  TasksViewController.swift
//  Priorities
//
//  Created by Jacob Covey on 1/2/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit
import Foundation

class TasksViewController: UITableViewController {
    
    var taskBank: TaskBank!
    var counter: Int = 0
    var newDayCounter: Int = 0
    var timeMovedToBackground: Date?
    var clockedIn: Bool = false
//    var addSecTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkForNewDay), userInfo: nil, repeats: true)
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    @IBAction func addTaskAlert(_ sender: Any) {
        let message = "What type of task would you like to add?"
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        let onceAction = UIAlertAction(title: "One Time", style: .default, handler: {(action) -> Void in
            self.performSegue(withIdentifier: "oneTimeTask", sender: nil)
        })
        alertController.addAction(onceAction)
        let repeatAction = UIAlertAction(title: "Repetitive", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "reptitiveTask", sender: nil)
        })
        alertController.addAction(repeatAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appBecameActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
//        self.clockedIn = self.checkForClockedIn()
//         if self.checkForClockedIn() != true {
//            self.addSecTimer.invalidate()
//        }
        
        
//        _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkForNewDay), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(secondTimer), userInfo: nil, repeats: true)
//        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTable), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print ("view appeared")
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print ("view disappeared")
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if TaskBank.sharedInstance.taskArrays[section].isEmpty {
            return nil
        } else {
            return TaskBank.sharedInstance.arrayNames[section]
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return TaskBank.sharedInstance.taskArrays.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TaskBank.sharedInstance.taskArrays[section].count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell
        if indexPath.row < TaskBank.sharedInstance.taskArrays[indexPath.section].count {
            let task = TaskBank.sharedInstance.taskArrays[indexPath.section][indexPath.row]
            cell.nameLabel.text = task.title
            if task.frequency == Frequency.Daily {
                cell.frequencyLabel.text = "Daily"
            } else if task.frequency == Frequency.Weekly {
                cell.frequencyLabel.text = "Weekly"
            } else if task.frequency == Frequency.Monthly {
                cell.frequencyLabel.text = "Monthly"
            } else {
                cell.frequencyLabel.text = "Once"
            }
            if task.type == TaskType.Time {
                cell.currentLabel.text = "Current: " + (task.currentTime?.toStringWithSec())!
                cell.goalLabel.text = "Goal: " + (task.goalTime?.toStringWithSec())!
                cell.iconButton.setImage(UIImage(named:"stopwatch"), for: UIControlState.normal)
            } else if task.type == TaskType.CheckOff {
                cell.currentLabel.text = "Current: " + String(describing: task.currentInt!)
                cell.goalLabel.text = "Goal: " + String(describing: task.goalInt!)
                cell.iconButton.setImage(UIImage(named:"plus-symbol"), for: UIControlState.normal)
            } else {
                cell.currentLabel.text = ""
                cell.goalLabel.text = ""
                cell.iconButton.setImage(UIImage(named:"checkmark"), for: UIControlState.normal)
            }
            cell.iconButton.tag = task.taskId
            cell.location.append(indexPath.section)
            cell.location.append(indexPath.row)
            cell.iconButton.addTarget(self, action: #selector(self.selectFunction), for: .touchUpInside)
            cell.iconView.tag = task.taskId
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectViewFunction))
            cell.iconView.addGestureRecognizer(tap)
            cell.iconView.isUserInteractionEnabled = true
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "taskDetail"?:
            if let indexPath = tableView.indexPathForSelectedRow {
                let task = TaskBank.sharedInstance.taskArrays[indexPath.section][indexPath.row]
                let taskDetailViewController = segue.destination as! TaskDetailViewController
                taskDetailViewController.task = task
            }
        default:
            break
        }
    }
    
    func appMovedToBackground() {
        print("App moved to background")
        self.timeMovedToBackground = Date()
    }
    
    func appBecameActive() {
        let elapsed = Date().timeIntervalSince(self.timeMovedToBackground!)
        let duration = Int(elapsed)
        self.addSecToAllTimedTasks(seconds: duration)
    }
    
    func updateTable() {
        self.checkTasksForCompletion()
        tableView.reloadData()
    }
    
    func secondTimer() {
        if self.checkForClockedIn() == true {
            self.addSecToAllTimedTasks(seconds: 1)
        }
        self.newDayCounter += 1
        if self.newDayCounter == 60 {// one a minute check if it is a new day
            if TaskBank.sharedInstance.checkIfNewDate() {
                TaskBank.sharedInstance.resetForNewDate()
            }
            self.newDayCounter = 0
        }
        self.updateTable()
    }
    
    func checkForNewDay() {
        if TaskBank.sharedInstance.checkIfNewDate() {
            TaskBank.sharedInstance.resetForNewDate()
        }
    }
    
    func checkForClockedIn() ->Bool {
        for arr in TaskBank.sharedInstance.taskArrays {
            for task in arr {
                if task.type == TaskType.Time && task.clockedIn == true {
                    return true
                }
            }
        }
        return false
    }
    
    func checkTasksForCompletion() {
        for taskArray in TaskBank.sharedInstance.taskArrays {
            for task in taskArray {
                if task.type == TaskType.Once {
                    if task.currentInt! >= 1 {
                        TaskBank.sharedInstance.removeTaskFromBank(task: task)
                    }
                } else if task.type == TaskType.CheckOff {
                    if task.currentInt! >= task.goalInt! {
                        TaskBank.sharedInstance.moveTaskToCompleted(task: task)
                    }
                } else if task.type == TaskType.Time {
                    if (task.currentTime?.getTotalSeconds())! >= (task.goalTime?.getTotalSeconds())! {
                        TaskBank.sharedInstance.moveTaskToCompleted(task: task)
                    }
                }
            }
        }
    }
    
    func addSecToAllTimedTasks(seconds: Int) {
        for arr in TaskBank.sharedInstance.taskArrays {
            for task in arr {
                if task.type == TaskType.Time && task.clockedIn == true {
                    task.currentTime?.addSeconds(seconds)
                }
            }
        }
    }
    
    func selectViewFunction(_ sender: UITapGestureRecognizer) {
        for arr in TaskBank.sharedInstance.taskArrays {
            for task in arr {
                if sender.view?.tag == task.taskId {
                    if task.type == TaskType.Time {
                        task.switchClocked()
                    } else {
                        task.currentInt = task.currentInt! + 1
                    }
                }
            }
        }
        self.updateTable()
    }
    
    func selectFunction(sender: UIButton) {
        for arr in TaskBank.sharedInstance.taskArrays {
            for task in arr {
                if sender.tag == task.taskId {
                    if task.type == TaskType.Time {
                        task.switchClocked()
                    } else {
                        task.currentInt = task.currentInt! + 1
                    }
                }
            }
        }
        self.updateTable()
    }
    
    
}
