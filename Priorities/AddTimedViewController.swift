//
//  AddTimedViewController.swift
//  Priorities
//
//  Created by Jacob Covey on 1/3/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class AddTimedViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
   
    var frequency:Frequency = .Daily
    var taskTitle:String!
    var urgent:Bool!
    var important:Bool!
    var goalTime:HourMinSec = HourMinSec(hour: 0, min: 0, sec: 0)
    var timePickerData = [[String]]()
    
    @IBOutlet var timeFrameSegControl: UISegmentedControl!
    @IBOutlet var goalTimePicker: UIPickerView!
    @IBOutlet var saveAndCloseButton: UIButton!
    
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
        self.goalTime.hour = Int(timePickerData[0][goalTimePicker.selectedRow(inComponent: 0)])!
        self.goalTime.min = Int(timePickerData[2][goalTimePicker.selectedRow(inComponent: 2)])!
        let timedTask:Task = Task(title: self.taskTitle, urgent: self.urgent, important: self.important, frequency: self.frequency, type: TaskType.Time, goalTime: self.goalTime, goalInt: nil, reminderDate: nil)
//        TaskBank.sharedInstance.allTasks.append(timedTask)
        TaskBank.sharedInstance.addTaskToBank(task: timedTask)
        
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = self.taskTitle
        
        self.loadPickerArrays()
        self.goalTimePicker.dataSource = self
        self.goalTimePicker.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timePickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(timePickerData[component][row])
    }

    func loadPickerArrays() {
        var hourPicker = [String]()
        var minPicker = [String]()
        var colonArr = [String]()
        for i in 0...999 {
            hourPicker.append(String(i))
        }
        timePickerData.append(hourPicker)
        colonArr.append(":")
        timePickerData.append(colonArr)
        for i in 0...59 {
            minPicker.append(String(i))
        }
        timePickerData.append(minPicker)
    }
}
