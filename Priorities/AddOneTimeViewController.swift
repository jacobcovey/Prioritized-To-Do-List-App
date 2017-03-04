//
//  AddOneTimeViewController.swift
//  Priorities
//
//  Created by Jacob Covey on 3/2/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class AddOneTimeViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var taskName: UITextField!
    @IBOutlet var urgentSwitch: UISwitch!
    @IBOutlet var importantSwitch: UISwitch!
    
    @IBOutlet var notesLabel: UILabel!
    @IBOutlet var reminderLabel: UILabel!
    
    var reminderDate: ReminderDate?
    
    var name: String = ""
    var isUrgent: Bool = false
    var isImportant: Bool = false
    var notes: String?
    
    
    
    @IBAction func saveAndQuit(_ sender: Any) {
        name = taskName.text ?? ""
        isUrgent = urgentSwitch.isOn
        isImportant = importantSwitch.isOn
        var oneTimeTask: Task
        oneTimeTask = Task(title: name, urgent: isUrgent, important: isImportant, frequency: Frequency.Once, type: TaskType.Once, goalTime: nil, goalInt: 1, reminderDate: reminderDate, notes: notes)
        TaskBank.sharedInstance.addTaskToBank(task: oneTimeTask)
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func urgentToggled(_ sender: Any) {
        taskName.resignFirstResponder()
    }
    @IBAction func importantToggled(_ sender: Any) {
        taskName.resignFirstResponder()
    }
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.contentInset = UIEdgeInsetsMake(-24, 0, 0, 0)
        
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
        
        if TaskBank.sharedInstance.reminderDateSet == true  {
            TaskBank.sharedInstance.reminderDateSet = false
            self.reminderDate = TaskBank.sharedInstance.reminderDate
            self.reminderLabel.text = dateFormatter.string(from: (self.reminderDate?.date)!)
        } else if reminderDate != nil {
            self.reminderLabel.text = dateFormatter.string(from: (self.reminderDate?.date)!)
        } else {
            self.reminderLabel.text = "(optional)"
            self.reminderDate = nil
        }
        
        if TaskBank.sharedInstance.notesSet == true  {
            TaskBank.sharedInstance.notesSet = false
            notes = TaskBank.sharedInstance.notes
            notesLabel.text = notes
        } else if notes != nil {
            notesLabel.text = notes
        } else {
            if notes == nil {
                notesLabel.text = "Notes (optional)"
            } else {
                notesLabel.text = notes
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "addNotes"?:
            let notesViewController = segue.destination as! NotesViewController
            notesViewController.notes = self.notes
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
            return newLength <= 35
        } else if UIDevice().type == .iPhone6 || UIDevice().type == .iPhone6S || UIDevice().type == .iPhone7 || UIDevice().type == .simulator {
            return newLength <= 30
        } else {
            return newLength <= 25
        }
    }
    

}