//
//  NotesViewController.swift
//  Priorities
//
//  Created by Jacob Covey on 2/21/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var textField: UITextView!
    var notes: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Notes"
        self.textField.layer.borderWidth = 1.0
        self.textField.layer.cornerRadius = 6.0
        self.textField.layer.borderColor = UIColor.lightGray.cgColor
        self.textField.delegate = self
        self.textField.becomeFirstResponder()
        self.textField.layer.borderWidth = 0
        self.automaticallyAdjustsScrollViewInsets = false
        if notes != nil && notes != "" {
            self.textField.text = notes
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if textField.text != nil {
            TaskBank.sharedInstance.notesSet = true
            TaskBank.sharedInstance.notes = textField.text
        }
    }
    
    func textFieldShouldReturn(_ textView: UITextView) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @IBAction func tap(_ sender: Any) {
        textField.resignFirstResponder()
    }
}
