//
//  AddOnceTimeTaskViewController.swift
//  Priorities
//
//  Created by Jacob Covey on 1/14/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class AddOneTimeTaskViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var taskName: UITextField!
    @IBOutlet var urgentSwitch: UISwitch!
    @IBOutlet var importantSwitch: UISwitch!
    
    @IBOutlet var reminderLabel: UILabel!
    var reminderDate: ReminderDate?
    @IBOutlet var alarmButton: UIButton!
    
    var name: String = ""
    var isUrgent: Bool = false
    var isImportant: Bool = false
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        taskName.resignFirstResponder()
    }
    @IBAction func saveAndQuit(_ sender: Any) {
        name = taskName.text ?? ""
        isUrgent = urgentSwitch.isOn
        isImportant = importantSwitch.isOn
        
        let oneTimeTask:Task = Task(title: name, urgent: isUrgent, important: isImportant, frequency: Frequency.Once, type: TaskType.Once, goalTime: nil, goalInt: 1, reminderDate: self.reminderDate!)
//        TaskBank.sharedInstance.allTasks.append(oneTimeTask)
        TaskBank.sharedInstance.addTaskToBank(task: oneTimeTask)
        
        self.navigationController?.popViewController(animated: true)
//        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    @IBAction func urgentToggled(_ sender: Any) {
        taskName.resignFirstResponder()
    }
    @IBAction func importantToggled(_ sender: Any) {
        taskName.resignFirstResponder()
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, d h:mm a"
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.taskName.delegate = self
        navigationItem.title = "Add Task"
        if TaskBank.sharedInstance.reminderDateSet == true {
            TaskBank.sharedInstance.reminderDateSet = false
            self.reminderDate = TaskBank.sharedInstance.reminderDate
            self.reminderLabel.text = dateFormatter.string(from: (self.reminderDate?.date)!)
            self.alarmButton.setTitle("Edit", for: .normal)
        } else {
            self.reminderLabel.text = "n/a"
            self.alarmButton.setTitle("set alarm", for: .normal)
            self.reminderDate = nil
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
    
}
