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
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.barTintColor = UIColor(red: 88, green: 116, blue: 152)
        let imageView = UIImageView(image: UIImage(named: "habit hero white"))
        self.navigationItem.titleView = imageView
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = (titleDict as! [String : Any])
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appBecameActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        if UIDevice().type == .iPhone6plus || UIDevice().type == .iPhone6Splus || UIDevice().type == .iPhone7plus || UIDevice().type == .simulator{
            tableView.rowHeight = 40
        } else {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 40
        }
        print ("view did load")

        if TaskBank.sharedInstance.currentId == 0 && TaskBank.sharedInstance.firstTime == true {
            let message = "Habit Hero is here to help you spend your time in more meaningful ways. To get started go ahead and tap the ➕ in the top right corner of the screen to add your first task.\n\nIf you are ever unsure about a screen or how to do something just click the ℹ︎ at the top of any screen for info and instructions."
            let alertController = UIAlertController(title: "Thanks for using Habit Hero!", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Got it", style: .cancel, handler: { (action) -> Void in
            })
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
        
        
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(secondTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print ("view appeared")
        if TaskBank.sharedInstance.checkIfNewDate() {
            TaskBank.sharedInstance.resetForNewDate()
        }
        TaskBank.sharedInstance.setTasksLastUpdated()
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if TaskBank.sharedInstance.taskArrays[section].isEmpty {
            return nil
        } else {
            let label = UILabel(frame: CGRect(x: 10, y: 6, width: view.frame.size.width, height: 20))
            
            label.text = TaskBank.sharedInstance.arrayNames[section]
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 18)
  
            let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
            
            if label.text == "Important & Urgent"{
                returnedView.backgroundColor = UIColor(red: 232, green: 104, blue: 80)
            } else if label.text == "Important" {
                returnedView.backgroundColor = UIColor(red: 255, green: 150, blue: 0)
            } else if label.text == "Urgent" {
                returnedView.backgroundColor = UIColor(red: 88, green: 112, blue: 88)
            } else if label.text == "To-do" {
                returnedView.backgroundColor = UIColor(red: 255, green: 216, blue: 0)
            } else if label.text == "Completed" {
                returnedView.backgroundColor = UIColor(red: 88, green: 116, blue: 152)
            } else {
                returnedView.backgroundColor = UIColor.lightGray
            }
            returnedView.addSubview(label)
            return returnedView
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
            
            if UIDevice().type == .iPhone6plus || UIDevice().type == .iPhone6Splus || UIDevice().type == .iPhone7plus || UIDevice().type == .simulator{
                let length = task.title.characters.count
                let spacesCount = 37 - length
                var spaces = ""
                if spacesCount > 0 {
                    for _ in 1...spacesCount {
                        spaces += " "
                    }
                }
                cell.nameLabel.text = task.title + spaces
            } else {
                cell.nameLabel.text = task.title
            }
            
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
                cell.repetitiveSpecificView.isHidden = false
                cell.currentLabel.text = "Current: " + (task.currentTime?.toStringWithSec())!
                cell.goalLabel.text = "Goal: " + (task.goalTime?.toStringWithSec())!
                    if task.important == true && task.urgent == true {
                        cell.iconButton.setImage(UIImage(named:"Stop Watch red"), for: UIControlState.normal)
                    } else if task.important == true && task.urgent == false {
                        cell.iconButton.setImage(UIImage(named:"Stop Watch orange"), for: UIControlState.normal)
                    } else if task.important == false && task.urgent == true {
                        cell.iconButton.setImage(UIImage(named:"Stop Watch green"), for: UIControlState.normal)
                    } else {
                        cell.iconButton.setImage(UIImage(named:"Stop Watch yellow"), for: UIControlState.normal)
                    }
            } else if task.type == TaskType.CheckOff {
                cell.repetitiveSpecificView.isHidden = false
                cell.currentLabel.text = "Current: " + String(describing: task.currentInt!)
                cell.goalLabel.text = "Goal: " + String(describing: task.goalInt!)
                    if task.important == true && task.urgent == true {
                        cell.iconButton.setImage(UIImage(named:"Plus sign red"), for: UIControlState.normal)
                    } else if task.important == true && task.urgent == false {
                        cell.iconButton.setImage(UIImage(named:"Plus sign orange"), for: UIControlState.normal)
                    } else if task.important == false && task.urgent == true {
                        cell.iconButton.setImage(UIImage(named:"Plus sign green"), for: UIControlState.normal)
                    } else {
                        cell.iconButton.setImage(UIImage(named:"Plus sign yellow"), for: UIControlState.normal)
                    }
            } else {
                cell.currentLabel.text = ""
                cell.goalLabel.text = ""
                cell.repetitiveSpecificView.isHidden = true
                    if task.important == true && task.urgent == true {
                        cell.iconButton.setImage(UIImage(named:"Checkmark red"), for: UIControlState.normal)
                    } else if task.important == true && task.urgent == false {
                        cell.iconButton.setImage(UIImage(named:"Checkmark orange"), for: UIControlState.normal)
                    } else if task.important == false && task.urgent == true {
                        cell.iconButton.setImage(UIImage(named:"Checkmark green"), for: UIControlState.normal)
                    } else {
                        cell.iconButton.setImage(UIImage(named:"Checkmark yellow"), for: UIControlState.normal)
                    }
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
        case "oneTimeDetail"?:
            if let indexPath = tableView.indexPathForSelectedRow {
                let task = TaskBank.sharedInstance.taskArrays[indexPath.section][indexPath.row]
                let oneTimeDetailController = segue.destination as! OneTimeDetailController
                oneTimeDetailController.task = task
            }
        case "checkOffDetail"?:
            if let indexPath = tableView.indexPathForSelectedRow {
                let task = TaskBank.sharedInstance.taskArrays[indexPath.section][indexPath.row]
                let checkOffDetailController = segue.destination as! CheckOffDetailController
                checkOffDetailController.task = task
            }
        case "timedDetail"?:
            if let indexPath = tableView.indexPathForSelectedRow {
                let task = TaskBank.sharedInstance.taskArrays[indexPath.section][indexPath.row]
                let timedDetailController = segue.destination as! TimedDetailController
                timedDetailController.task = task
            }
        default:
            break
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = TaskBank.sharedInstance.taskArrays[indexPath.section][indexPath.row]
        if task.type == TaskType.Once {
            self.performSegue(withIdentifier: "oneTimeDetail", sender: nil)
        } else if task.type == TaskType.CheckOff {
            self.performSegue(withIdentifier: "checkOffDetail", sender: nil)
        } else if task.type == TaskType.Time {
            self.performSegue(withIdentifier: "timedDetail", sender: nil)
        }
    }
    
    func appMovedToBackground() {
        print("App moved to background")
        self.timeMovedToBackground = Date()
    }
    
    func appBecameActive() {
        if TaskBank.sharedInstance.checkIfNewDate() {
            TaskBank.sharedInstance.resetForNewDate()
        }
        TaskBank.sharedInstance.setTasksLastUpdated()
        
        var elapsed: Double = 0.0;
        if (self.timeMovedToBackground != nil) {
        elapsed = Date().timeIntervalSince(self.timeMovedToBackground!)
        }
        let duration = Int(elapsed)
        self.addSecToAllTimedTasks(seconds: duration)
    }
    
    func reloadTableView(_ tableView: UITableView) {
        self.checkTasksForCompletion()
        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(contentOffset, animated: false)
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
        self.reloadTableView(self.tableView)
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
                        TaskBank.sharedInstance.moveTaskToCompleted(task: task)
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
                        self.updateCompletionAlert(task: task)
                        task.switchClocked()
                    } else {
                        task.currentInt = task.currentInt! + 1
                    }
                }
            }
        }
        self.reloadTableView(self.tableView)
    }
    
    func selectFunction(sender: UIButton) {
        for arr in TaskBank.sharedInstance.taskArrays {
            for task in arr {
                if sender.tag == task.taskId {
                    if task.type == TaskType.Time {
                        self.updateCompletionAlert(task: task)
                        task.switchClocked()
                    } else {
                        task.currentInt = task.currentInt! + 1
                    }
                }
            }
        }
        self.reloadTableView(self.tableView)
    }
    
    func updateCompletionAlert(task: Task) {
        let id = "c" + String(task.taskId)
        if task.clockedIn == false {
                let diff = task.secondsCurrentLessThanGoal()
                print("diff: " + String(diff))
                if diff > 0 {
                let message = "You hit your goal time for \"\(task.title)\" 👍"
                let title = "🎉 Task Completed "
                let date = Date(timeIntervalSinceNow: TimeInterval(diff))
                let reminderDate = ReminderDate(date: date, frequency: .Once, type: .Once, weekday: nil)
                print(date)
                    
                let reminder = Reminder(reminderDate: reminderDate, title: title, message: message, id: id)
                TaskBank.sharedInstance.reminders.append(reminder)
                let delegate = UIApplication.shared.delegate as? AppDelegate
                delegate?.updateScheduledNotification()
            }
        } else {
            TaskBank.sharedInstance.removeAlarmWithId(id: id)
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.updateScheduledNotification()
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}
