//
//  ReminderPickerController.swift
//  Priorities
//
//  Created by Jacob Covey on 2/18/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class ReminderPickerController: UIViewController {
    
//    var date: Date?
//    var reminderSet: Bool?
//    var reminderDate: ReminderDate!
    var reminderSet: Bool?
    
    @IBOutlet var datePicker: UIDatePicker!

    
    @IBAction func save(_ sender: Any) {
        self.reminderSet = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.reminderSet = false
        self.navigationController?.popViewController(animated: true)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Reminder"
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.reminderSet != nil {
            TaskBank.sharedInstance.reminderDate = ReminderDate(date: datePicker.date, frequency: .Once, type: .Once, weekday: nil)
            TaskBank.sharedInstance.reminderDateSet = self.reminderSet!
        }
    }
}

