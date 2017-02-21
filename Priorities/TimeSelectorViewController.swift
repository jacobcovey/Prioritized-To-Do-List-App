//
//  TimeSelectorViewController.swift
//  Priorities
//
//  Created by Jacob Covey on 1/28/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class TimeSelectorViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    

    @IBOutlet var timePicker: UIPickerView!
    var current: Bool!
    var task: Task!
    var timePickerData = [[String]]()
    var newTime:HourMinSec = HourMinSec(hour: 0, min: 0, sec: 0)
    var oldTime:HourMinSec!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.current == true {
            navigationItem.title = "Select Current Time"
            self.oldTime = self.task.currentTime
        } else {
            navigationItem.title = "Select Goal Time"
            self.oldTime = self.task.goalTime
        }
        

//        self.timePicker.selectRow(5, inComponent: 2, animated: false)
        self.loadPickerArrays()
        self.timePicker.dataSource = self
        self.timePicker.delegate = self
        self.timePicker.selectRow(oldTime.hour, inComponent: 0, animated: true)
        self.timePicker.selectRow(oldTime.min, inComponent: 2, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.newTime.hour = Int(timePickerData[0][timePicker.selectedRow(inComponent: 0)])!
        self.newTime.min = Int(timePickerData[2][timePicker.selectedRow(inComponent: 2)])!
        if self.current == true {
            self.task.currentTime = self.newTime
        } else {
            self.task.goalTime = self.newTime
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
