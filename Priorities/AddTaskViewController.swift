//
//  AddTaskViewController.swift
//  Priorities
//
//  Created by Jacob Covey on 1/3/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var urgentSwitch: UISwitch!
    @IBOutlet var importantSwitch: UISwitch!
    @IBOutlet var taskName: UITextField!
    
    var name: String = ""
    var isUrgent: Bool = false
    var isImportant: Bool = false
    
    @IBAction func urgentToggled(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func importantToggled(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        taskName.resignFirstResponder()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.taskName.delegate = self
        navigationItem.title = "Add Task"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        name = taskName.text ?? ""
        isUrgent = urgentSwitch.isOn
        isImportant = importantSwitch.isOn
        switch segue.identifier {
        case "addTimedTask"?:
            let addTimedViewController = segue.destination as! AddTimedViewController
            addTimedViewController.taskTitle = name
            addTimedViewController.urgent = isUrgent
            addTimedViewController.important = isImportant
            break
        case "addCheckOffTask"?:
            let addCheckOffViewController = segue.destination as! AddCheckOffViewController
            addCheckOffViewController.taskTitle = name
            addCheckOffViewController.urgent = isUrgent
            addCheckOffViewController.important = isImportant
            break
        default:
            break
//            preconditionFailure("Unexpected segue identifier")
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
        if UIDevice().type == .iPhone6plus || UIDevice().type == .iPhone6Splus || UIDevice().type == .iPhone7plus || UIDevice().type == .simulator{
            return newLength <= 21
        } else if UIDevice().type == .iPhone6 || UIDevice().type == .iPhone6S || UIDevice().type == .iPhone7 {
            return newLength <= 16
        } else {
            return newLength <= 13
        }
    }
}
