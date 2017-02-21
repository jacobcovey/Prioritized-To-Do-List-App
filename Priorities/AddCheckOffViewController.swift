//
//  AddCheckOffViewController.swift
//  Priorities
//
//  Created by Jacob Covey on 1/3/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class AddCheckOffViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var taskTitle:String!
    var urgent:Bool!
    var important:Bool!
    var frequency:Frequency = .Daily
    var goalPickerData = [String]()
    var reminderDate: ReminderDate?
    
    @IBOutlet var frequencySegControl: UISegmentedControl!
    @IBOutlet var goalIntPicker: UIPickerView!
    @IBOutlet var saveAndCloseButton: UIButton!
    @IBOutlet var reminderLabel: UILabel!
    @IBOutlet var reminderButton: UIButton!
    
    
    @IBAction func setControlAction(_ sender: Any) {
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
    @IBAction func saveAndClose(_ sender: UIButton) {
        let checkOffTask:Task = Task(title: self.taskTitle, urgent: self.urgent, important: self.important, frequency: self.frequency, type: TaskType.CheckOff, goalTime: nil, goalInt: Int(goalPickerData[goalIntPicker.selectedRow(inComponent: 0)]), reminderDate: self.reminderDate)
//        TaskBank.sharedInstance.allTasks.append(checkOffTask)
        TaskBank.sharedInstance.addTaskToBank(task: checkOffTask)
        
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = self.taskTitle
        
        self.loadPickerData()
        self.goalIntPicker.dataSource = self
        self.goalIntPicker.delegate = self
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
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return goalPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return goalPickerData[row]
    }
    
    func loadPickerData() {
        for i in 1...999 {
            self.goalPickerData.append(String(i))
        }
    }
}
