//
//  TaskDetailViewController.swift
//  Priorities
//
//  Created by Jacob Covey on 1/28/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var taskName: UITextField!
    @IBOutlet var taskTypeLabel: UILabel!
    @IBOutlet var urgentSwitch: UISwitch!
    @IBOutlet var importantSwitch: UISwitch!
    @IBOutlet var frequencySegControl: UISegmentedControl!
    @IBOutlet var reminderLabel: UILabel!
    @IBOutlet var reminderButton: UIButton!
//    @IBOutlet var oneTimeSpecificView: UIStackView!

    @IBOutlet var notesLabel: UILabel!
    @IBOutlet var oneTimeSpecificView: UIStackView!
    @IBOutlet var goalIntLabel: UILabel!
    @IBOutlet var currentIntLabel: UILabel!
    @IBOutlet var currentTimedLabel: UILabel!
    @IBOutlet var goalTimedLabel: UILabel!
    @IBOutlet var repetitveSpecificView: UIStackView!
    @IBOutlet var timedSpecificView: UIStackView!
    @IBOutlet var checkOffSpecificView: UIStackView!
    @IBOutlet var currentIntStepper: UIStepper!
    @IBOutlet var goalIntStepper: UIStepper!
    var delete = false
    var task: Task! {
        didSet {
            name = task.title
        }
    }
    
    var name: String = ""
    var isUrgent: Bool = false
    var isImportant: Bool = false
    
    @IBAction func changeSegControl(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func urgentToggle(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func importantToggle(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func dissmissKeyboard(_ sender: Any) {
        taskName.resignFirstResponder()
    }
    @IBAction func deleteTask(_ sender: Any) {
        self.view.endEditing(true)
        let title = "Delete \(self.task.title)?"
        let message = "Are you sure you want to delete this task?"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) -> Void in
//            TaskBank.sharedInstance.removeTaskFromBank(task: self.task)
            self.delete = true
            self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func currentAdjust(_ sender: Any) {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: "showCurrentTime", sender: nil)
    }
    @IBAction func goalAdjust(_ sender: Any) {
        self.view.endEditing(true)
        self.performSegue(withIdentifier: "showGoalTime", sender: nil)
    }
    @IBAction func saveAndClose(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func currentStepper(_ sender: UIStepper) {
        self.view.endEditing(true)
        currentIntLabel.text = Int(sender.value).description
    }
    @IBAction func goalStepper(_ sender: UIStepper) {
        self.view.endEditing(true)
        goalIntLabel.text = Int(sender.value).description
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, d h:mm a"
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TaskBank.sharedInstance.updateReminders()
        self.taskName.delegate = self
        navigationItem.title = "Task Details"
        let attString = NSAttributedString(string: self.task.title)
        taskName.attributedText = attString
        urgentSwitch.isOn = self.task.urgent
        importantSwitch.isOn = self.task.important
        
        if task.type == TaskType.Once {
            taskTypeLabel.text = "One Time"
            repetitveSpecificView.isHidden = true
            if TaskBank.sharedInstance.reminderDateSet == true {
                TaskBank.sharedInstance.reminderDateSet = false
                task.reminderDate = TaskBank.sharedInstance.reminderDate
                self.reminderLabel.text = dateFormatter.string(from: (task.reminderDate?.date)!)
                self.reminderButton.setTitle("Edit", for: .normal)
            } else if task.reminderDate != nil && TaskBank.sharedInstance.deleteReminder == false {
                self.reminderLabel.text = dateFormatter.string(from: (task.reminderDate?.date)!)
                self.reminderButton.setTitle("Edit", for: .normal)
            } else {
                self.reminderLabel.text = "n/a"
                self.reminderButton.setTitle("set alarm", for: .normal)
                task.reminderDate = nil
            }
            
            if TaskBank.sharedInstance.notesSet == true {
                TaskBank.sharedInstance.notesSet = false
                task.notes = TaskBank.sharedInstance.notes
                notesLabel.text = task.notes
            } else {
                if task.notes == nil {
                    notesLabel.text = "n/a"
                } else {
                    notesLabel.text = task.notes
                }
            }
        } else {
            oneTimeSpecificView.isHidden = true
            if task.frequency == Frequency.Daily {
                frequencySegControl.selectedSegmentIndex = 0
            } else if task.frequency == Frequency.Weekly {
                frequencySegControl.selectedSegmentIndex = 1
            } else {
                frequencySegControl.selectedSegmentIndex = 2
            }
            if task.type == TaskType.CheckOff {
                currentIntStepper.value = Double(self.task.currentInt!)
                goalIntStepper.value = Double(self.task.goalInt!)
                timedSpecificView.isHidden = true
                taskTypeLabel.text = "Check-off"
                currentIntLabel.text = String(describing: task.currentInt!)
                goalIntLabel.text = String(describing: task.goalInt!)
            } else {
                checkOffSpecificView.isHidden = true
                taskTypeLabel.text = "Timed"
                currentTimedLabel.text = task.currentTime!.toStringWOsec()
                goalTimedLabel.text = task.goalTime!.toStringWOsec()
            }
            if TaskBank.sharedInstance.reminderDateSet == true {
                TaskBank.sharedInstance.reminderDateSet = false
                task.reminderDate = TaskBank.sharedInstance.reminderDate
                self.reminderLabel.text = reptitiveReminderString()
                self.reminderButton.setTitle("Edit", for: .normal)
            } else if task.reminderDate != nil && TaskBank.sharedInstance.deleteReminder == false {
                self.reminderLabel.text = reptitiveReminderString()
                self.reminderButton.setTitle("Edit", for: .normal)
            } else {
                self.reminderLabel.text = "n/a"
                self.reminderButton.setTitle("set alarm", for: .normal)
                task.reminderDate = nil
            }
        }
        
    }
    
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
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TaskBank.sharedInstance.removeTaskFromBank(task: self.task)
        self.task.title = (taskName.attributedText?.string)!
        self.task.urgent = urgentSwitch.isOn
        self.task.important = importantSwitch.isOn
        if task.type != TaskType.Once {
            if frequencySegControl.selectedSegmentIndex == 0 {
                self.task.frequency = Frequency.Daily
            } else if frequencySegControl.selectedSegmentIndex == 1 {
                self.task.frequency = Frequency.Weekly
            } else if frequencySegControl.selectedSegmentIndex == 2 {
                self.task.frequency = Frequency.Monthly
            }
            
            if task.type == TaskType.CheckOff {
                task.currentInt = Int(currentIntStepper.value)
                task.goalInt = Int(goalIntStepper.value)
            }
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
            if task.frequency == .Once {
                reminderPickerController.repeate = false
            } else {
                reminderPickerController.repeate = true
            }
            reminderPickerController.frequency = self.task.frequency
            break
        case "addNotes"?:
            let notesViewController = segue.destination as! NotesViewController
            notesViewController.notes = task.notes
        default:
            break
            //            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}

