//
//  AddRepetitiveViewController.swift
//  Priorities
//
//  Created by Jacob Covey on 3/2/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class AddRepetitiveViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var taskName: UITextField!
    @IBOutlet var urgentSwitch: UISwitch!
    @IBOutlet var importantSwitch: UISwitch!

    
    @IBOutlet var frequencySegControl: UISegmentedControl!
    @IBOutlet var goalTypeSegControl: UISegmentedControl!
    
    @IBOutlet var goalLabel: UILabel!
    @IBOutlet var reminderLabel: UILabel!
    
    var reminderDate: ReminderDate?
    
    var name: String = ""
    var isUrgent: Bool = false
    var isImportant: Bool = false
    var goalTimeIsSet: Bool = false
    var goalIntIsSet: Bool = false
    var frequency:Frequency = .Daily
    var type:TaskType = .Time
    var goalInt: Int = 0
    var goalTime:HourMinSec = HourMinSec(hour: 0, min: 0, sec: 0)
    
    @IBAction func frequencySegAction(_ sender: Any) {
        switch frequencySegControl.selectedSegmentIndex {
        case 0:
            frequency = .Daily
        case 1:
            frequency = .Weekly
        case 2:
            frequency = .Monthly
        default:
            break
        }
    }
    
    @IBAction func typeSegAction(_ sender: Any) {
        switch goalTypeSegControl.selectedSegmentIndex {
        case 0:
            type = .Time
            if self.goalTimeIsSet {
                self.goalLabel.text = self.goalTime.toStringWOsec()
            } else {
                self.goalLabel.text = "(required)"
            }
        case 1:
            type = .CheckOff
            if self.goalIntIsSet {
                self.goalLabel.text = String(self.goalInt)
            } else {
                self.goalLabel.text = "(required)"
            }
        default:
            break
        }
    }
    
    @IBAction func urgentToggle(_ sender: Any) {
        taskName.resignFirstResponder()
    }

    @IBAction func importantToggle(_ sender: Any) {
        taskName.resignFirstResponder()
    }
    @IBAction func createTask(_ sender: Any) {
        name = taskName.text ?? ""
        isUrgent = urgentSwitch.isOn
        isImportant = importantSwitch.isOn
        var repetitiveTask: Task
        if type == TaskType.Time && goalTimeIsSet {
            repetitiveTask = Task(title: name, urgent: isUrgent, important: isImportant, frequency: frequency, type: type, goalTime: goalTime, goalInt: nil, reminderDate: reminderDate, notes: nil)
            TaskBank.sharedInstance.addTaskToBank(task: repetitiveTask)
        } else if type == TaskType.CheckOff && goalIntIsSet {
            repetitiveTask = Task(title: name, urgent: isUrgent, important: isImportant, frequency: frequency, type: type, goalTime: nil, goalInt: goalInt, reminderDate: reminderDate, notes: nil)
            TaskBank.sharedInstance.addTaskToBank(task: repetitiveTask)
        } else {
            let message = "It looks you forgot to set a goal for the task. To set a goal just tap on the \"Goal\" cell. "
            let alertController = UIAlertController(title: "Goal Missing", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Got it", style: .cancel, handler: { (action) -> Void in
            })
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
        
        
        self.navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            if self.type == .Time {
                self.performSegue(withIdentifier: "timedGoal", sender: nil)
            } else {
                self.performSegue(withIdentifier: "intGoal", sender: nil)
            }
        }
    }

    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if TaskBank.sharedInstance.currentId == 0 && TaskBank.sharedInstance.firstTime == true {
            TaskBank.sharedInstance.firstTime = false
            let message = "This app is designed to help you proritize important tasks over tasks that are just urgent. This is important because it is in our nature to only focus on what is urgent.\n\nEvery task you enter will have a level of importance to it, but we encourage you to only mark important on those task where your quality of life will suffer if you don’t perform the task."
            let alertController = UIAlertController(title: "One last thing...", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Got it", style: .cancel, handler: { (action) -> Void in
            })
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
        
        self.taskName.delegate = self
        navigationItem.title = "Add Task"
        
        self.tableView.contentInset = UIEdgeInsetsMake(-24, 0, 0, 0)
        
        if TaskBank.sharedInstance.reminderDateSet == true  {
            TaskBank.sharedInstance.reminderDateSet = false
            self.reminderDate = TaskBank.sharedInstance.reminderDate
            self.reminderLabel.text = reptitiveReminderString()
        }
        else if reminderDate != nil {
//            self.reminderLabel.text = reptitiveReminderString()
            self.reminderLabel.text = "(optional)"
            self.reminderDate = nil
        }
        if TaskBank.sharedInstance.goalIntSet == true {
            self.goalIntIsSet = true
            TaskBank.sharedInstance.goalIntSet = false
            goalInt = TaskBank.sharedInstance.goalInt!
            self.goalLabel.text = String(goalInt)
        } else if TaskBank.sharedInstance.goalTimeSet == true {
            self.goalTimeIsSet = true
            TaskBank.sharedInstance.goalTimeSet = false
            goalTime = TaskBank.sharedInstance.goalTime!
            self.goalLabel.text = goalTime.toStringWOsec()
        } else {
            self.goalLabel.text = "(required)"
        }
        
    }
    
    func reptitiveReminderString() -> String {
        let hourMin = timeFormatter.string(from: (self.reminderDate?.date)!)
        if self.reminderDate?.frequency == Frequency.Daily {
            return "Daily " + hourMin
        } else if self.reminderDate?.frequency == Frequency.Weekly{
            return convertNumToWeekday(num: (self.reminderDate?.weekday)!) + " " + hourMin
        } else if self.reminderDate?.frequency == Frequency.Monthly {
            if let day = self.reminderDate?.weekday {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "reminder"?:
            let reminderPickerController = segue.destination as! ReminderPickerController
            reminderPickerController.repeate = true
            reminderPickerController.frequency = self.frequency
//        case "timedGoal"?:
//            let addTaskTimePickerController = segue.destination as! AddTaskTimePickerController
        case "intGoal"?:
            let addTaskIntPickerController = segue.destination as! AddTaskIntPickerController
            addTaskIntPickerController.frequency = self.frequency
            break
        case "timedGoal"?:
            let addTaskTimerPicker = segue.destination as! AddTaskTimePickerController
            addTaskTimerPicker.frequency = self.frequency
            break
        default:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        name = taskName.text ?? ""
        isUrgent = urgentSwitch.isOn
        isImportant = importantSwitch.isOn
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        print(UIDevice().type)
        if UIDevice().type == .iPhone6plus || UIDevice().type == .iPhone6Splus || UIDevice().type == .iPhone7plus {
            return newLength <= 21
        } else if UIDevice().type == .iPhone6 || UIDevice().type == .iPhone6S || UIDevice().type == .iPhone7 || UIDevice().type == .simulator {
            return newLength <= 16
        } else {
            return newLength <= 13
        }
    }
    
    
}
