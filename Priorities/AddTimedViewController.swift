//
//  AddTimedViewController.swift
//  Priorities
//
//  Created by Jacob Covey on 1/3/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class AddTimedViewController: UIViewController {
   
    var frequency:Frequency = .Daily
    var taskTitle:String!
    var urgent:Bool!
    var important:Bool!
    var goalTime:HourMinSec = HourMinSec(hour: 0, min: 0, sec: 0)
    var reminderDate: ReminderDate?
    
    @IBOutlet var goalTimePicker: UIDatePicker!
    @IBOutlet var timeFrameSegControl: UISegmentedControl!
    @IBOutlet var saveAndCloseButton: UIButton!
    @IBOutlet var reminderLabel: UILabel!
    @IBOutlet var reminderButton: UIButton!
    
    @IBAction func segmentedControlAction(_ sender: Any) {
        switch timeFrameSegControl.selectedSegmentIndex {
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
    
    @IBAction func saveAndClose(_ sender: UIButton) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: goalTimePicker.date)
        goalTime.hour = components.hour!
        goalTime.min = components.minute!
        let timedTask:Task = Task(title: self.taskTitle, urgent: self.urgent, important: self.important, frequency: self.frequency, type: TaskType.Time, goalTime: self.goalTime, goalInt: nil, reminderDate: reminderDate, notes: nil)
//        TaskBank.sharedInstance.allTasks.append(timedTask)
        TaskBank.sharedInstance.addTaskToBank(task: timedTask)
        
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = self.taskTitle
        
//        self.loadPickerArrays()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if TaskBank.sharedInstance.reminderDateSet == true {
            TaskBank.sharedInstance.reminderDateSet = false
            self.reminderDate = TaskBank.sharedInstance.reminderDate
            self.reminderButton.setTitle("Edit", for: .normal)
            let hourMin = dateFormatter.string(from: (self.reminderDate?.date)!)
            if self.reminderDate?.frequency == Frequency.Daily {
                self.reminderLabel.text = "Daily " + hourMin
            } else if self.reminderDate?.frequency == Frequency.Weekly{
                self.reminderLabel.text = AddTimedViewController.convertNumToWeekday(num: (self.reminderDate?.weekday)!) + " " + hourMin
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
                    self.reminderLabel.text = "Monthly, " + day1 + " " + hourMin
                }
            }
        } else {
            self.reminderLabel.text = "n/a"
            self.reminderButton.setTitle("set alarm", for: .normal)
            self.reminderDate = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "repeatReminder"?:
            let reminderPickerController = segue.destination as! ReminderPickerController
            reminderPickerController.repeate = true
            reminderPickerController.frequency = self.frequency
            break
        default: break
//            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    
    static func convertNumToWeekday(num: Int)->String {
        var day = ""
        switch num {
            case 0 :
                day = "Sundays"
            case 1 :
                day = "Mondays"
            case 2 :
                day = "Tuesdays"
            case 3 :
                day = "Wednesdays"
            case 4 :
                day = "Thursdays"
            case 5 :
                day = "Fridays"
            case 6 :
                day = "Saturdays"
            default:
                day = "Error"
        }
        return day
    }
}
