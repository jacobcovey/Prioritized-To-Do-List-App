//
//  TimedDetailController.swift
//  Priorities
//
//  Created by Jacob Covey on 3/3/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class TimedDetailController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var taskName: UITextField!
    @IBOutlet var urgentSwitch: UISwitch!
    @IBOutlet var importantSwitch: UISwitch!
    @IBOutlet var frequencySegControl: UISegmentedControl!
    
    @IBOutlet var currentTimedLabel: UILabel!
    @IBOutlet var goalTimedLabel: UILabel!
    @IBOutlet var reminderLabel: UILabel!
    var delete = false
    var task: Task! {
        didSet {
            name = task.title
        }
    }
    var name: String = ""
    var isUrgent: Bool = false
    var isImportant: Bool = false
    
    @IBAction func urgentToggle(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func importantToggle(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func changeSegControl(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func deleteTask(_ sender: Any) {
        self.view.endEditing(true)
        let title = "Delete \(self.task.title)?"
        let message = "Are you sure you want to delete this task?"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) -> Void in
            self.delete = true
            self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func saveAndClose(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TaskBank.sharedInstance.updateReminders()
        self.taskName.delegate = self
        navigationItem.title = "Task Details"
        let attString = NSAttributedString(string: self.task.title)
        taskName.attributedText = attString
        urgentSwitch.isOn = self.task.urgent
        importantSwitch.isOn = self.task.important
        
        if task.frequency == Frequency.Daily {
            frequencySegControl.selectedSegmentIndex = 0
        } else if task.frequency == Frequency.Weekly {
            frequencySegControl.selectedSegmentIndex = 1
        } else {
            frequencySegControl.selectedSegmentIndex = 2
        }
        
        currentTimedLabel.text = task.currentTime!.toStringWOsec()
        goalTimedLabel.text = task.goalTime!.toStringWOsec()

        if TaskBank.sharedInstance.reminderDateSet == true {
            TaskBank.sharedInstance.reminderDateSet = false
            task.reminderDate = TaskBank.sharedInstance.reminderDate
            self.reminderLabel.text = reptitiveReminderString()
        } else if task.reminderDate != nil && TaskBank.sharedInstance.deleteReminder == false {
            self.reminderLabel.text = reptitiveReminderString()
        } else {
            self.reminderLabel.text = "n/a"
            task.reminderDate = nil
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TaskBank.sharedInstance.removeTaskFromBank(task: self.task)
        self.task.title = (taskName.attributedText?.string)!
        self.task.urgent = urgentSwitch.isOn
        self.task.important = importantSwitch.isOn
        if frequencySegControl.selectedSegmentIndex == 0 {
            self.task.frequency = Frequency.Daily
        } else if frequencySegControl.selectedSegmentIndex == 1 {
            self.task.frequency = Frequency.Weekly
        } else if frequencySegControl.selectedSegmentIndex == 2 {
            self.task.frequency = Frequency.Monthly
        }
        if self.delete == false {
            TaskBank.sharedInstance.addTaskToBank(task: self.task)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showCurrentTime"?:
            let timeSelectorViewController = segue.destination as! TimeSelectorViewController
            timeSelectorViewController.task = task
            timeSelectorViewController.current = true
        case "showGoalTime"?:
            let timeSelectorViewController = segue.destination as! TimeSelectorViewController
            timeSelectorViewController.task = task
            timeSelectorViewController.current = false
        case "reminder"?:
            let reminderPickerController = segue.destination as! ReminderPickerController
            reminderPickerController.repeate = true
            reminderPickerController.frequency = self.task.frequency
            break
        default:
            break
        }
    }
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    func reptitiveReminderString() -> String {
        let hourMin = timeFormatter.string(from: (self.task.reminderDate?.date)!)
        if self.task.reminderDate?.frequency == Frequency.Daily {
            return "Daily " + hourMin
        } else if self.task.reminderDate?.frequency == Frequency.Weekly{
            return AddTimedViewController.convertNumToWeekday(num: (self.task.reminderDate?.weekday)!) + " " + hourMin
        } else if self.task.reminderDate?.frequency == Frequency.Monthly {
            if let day = self.task.reminderDate?.weekday {
                var day1 = ""
                if day == 1{
                    day1 = String(day) + "st"
                } else if day == 1{
                    day1 = String(day) + "nd"
                } else if day == 1{
                    day1 = String(day) + "rd"
                }else{
                    day1 = String(day) + "th"
                }
                return "Monthly, " + day1 + " " + hourMin
            }
        }
        return "n/a"
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
