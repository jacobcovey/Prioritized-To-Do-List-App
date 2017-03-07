//
//  OneTimeDetailController.swift
//  Priorities
//
//  Created by Jacob Covey on 3/3/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class OneTimeDetailController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var taskName: UITextField!
    @IBOutlet var urgentSwitch: UISwitch!
    @IBOutlet var importantSwitch: UISwitch!
    @IBOutlet var reminderLabel: UILabel!
    @IBOutlet var notesLabel: UILabel!
    @IBOutlet var completedSwitch: UISwitch!
    
    var delete = false
    var task: Task! {
        didSet {
            name = task.title
        }
    }
    var name: String = ""
    var isUrgent: Bool = false
    var isImportant: Bool = false
    
    @IBAction func deleteTask(_ sender: Any) {
        self.view.endEditing(true)
        let title = "Delete \(self.task.title)?"
        let message = "Are you sure you want to delete this task?"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) -> Void in
            self.delete = true
           _ = self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func saveAndClose(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func urgentToggle(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func importantToggle(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func completedToggle(_ sender: Any) {
        self.view.endEditing(true)
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, d h:mm a"
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.tableView.contentInset = UIEdgeInsetsMake(-24, 0, 0, 0)
        TaskBank.sharedInstance.updateReminders()
        self.taskName.delegate = self
        navigationItem.title = "Task Details"
        let attString = NSAttributedString(string: self.task.title)
        taskName.attributedText = attString
        urgentSwitch.isOn = self.task.urgent
        importantSwitch.isOn = self.task.important
        if self.task.currentInt == 0 {
            completedSwitch.isOn = false
        } else {
            completedSwitch.isOn = true
        }
        
        if TaskBank.sharedInstance.reminderDateSet == true {
            TaskBank.sharedInstance.reminderDateSet = false
            task.reminderDate = TaskBank.sharedInstance.reminderDate
            self.reminderLabel.text = dateFormatter.string(from: (task.reminderDate?.date)!)
        } else if task.reminderDate != nil && TaskBank.sharedInstance.deleteReminder == false {
            self.reminderLabel.text = dateFormatter.string(from: (task.reminderDate?.date)!)
        } else {
            self.reminderLabel.text = "none"
            task.reminderDate = nil
        }
        
        if TaskBank.sharedInstance.notesSet == true {
            TaskBank.sharedInstance.notesSet = false
            task.notes = TaskBank.sharedInstance.notes
            if task.notes == ""{
                notesLabel.text = "Notes"
            }else {
                notesLabel.text = task.notes
            }
        } else {
            if task.notes == nil || task.notes == "" {
                notesLabel.text = "Notes"
            } else {
                notesLabel.text = task.notes
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TaskBank.sharedInstance.removeTaskFromBank(task: self.task)
        self.task.title = (taskName.attributedText?.string)!
        self.task.urgent = urgentSwitch.isOn
        self.task.important = importantSwitch.isOn
        if completedSwitch.isOn {
            self.task.currentInt = 1
            self.task.completed = true
        } else {
            self.task.currentInt = 0
            self.task.completed = false
        }
        if self.delete == false {
            TaskBank.sharedInstance.addTaskToBank(task: self.task)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "reminder"?:
            let reminderPickerController = segue.destination as! ReminderPickerController
            reminderPickerController.repeate = false
//            reminderPickerController.frequency = self.task.frequency
            break
        case "addNotes"?:
            let notesViewController = segue.destination as! NotesViewController
            notesViewController.notes = task.notes
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
