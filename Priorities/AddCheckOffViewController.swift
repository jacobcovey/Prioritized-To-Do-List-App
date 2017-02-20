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
    
    @IBOutlet var frequencySegControl: UISegmentedControl!
    @IBOutlet var goalIntPicker: UIPickerView!
    @IBOutlet var saveAndCloseButton: UIButton!
    
    
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
        let checkOffTask:Task = Task(title: self.taskTitle, urgent: self.urgent, important: self.important, frequency: self.frequency, type: TaskType.CheckOff, goalTime: nil, goalInt: Int(goalPickerData[goalIntPicker.selectedRow(inComponent: 0)]), reminderDate: nil)
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segue.identifier {
//        case "repeatReminder"?:
//            let reminderPickerController = segue.destination as! ReminderPickerController
//            reminderPickerController.repeate = true
//            break
//        default:
//            preconditionFailure("Unexpected segue identifier")
//        }
//    }
    
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
