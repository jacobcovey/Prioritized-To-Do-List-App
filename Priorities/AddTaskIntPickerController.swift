//
//  AddTaskIntPickerController.swift
//  Priorities
//
//  Created by Jacob Covey on 3/2/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class AddTaskIntPickerController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    

    
    @IBOutlet var intPicker: UIPickerView!
    var intPickerData = [[String]]()
    var newGoal: Int = 0
    var frequency: Frequency?
    var componentWidth = [CGFloat]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Goal"
        
        //        self.timePicker.selectRow(5, inComponent: 2, animated: false)
        self.loadPickerArrays()
        self.intPicker.dataSource = self
        self.intPicker.delegate = self
        self.componentWidth.append(50)
        self.componentWidth.append(200)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.newGoal = Int(intPickerData[0][intPicker.selectedRow(inComponent: 0)])!
        TaskBank.sharedInstance.goalIntSet = true
        TaskBank.sharedInstance.goalInt = self.newGoal
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
//    @IBAction func saveButtonClicked(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
//    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return intPickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(intPickerData[component][row])
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return componentWidth[component]
    }
    
    func loadPickerArrays() {
        var intPicker = [String]()
        var frequencyPicker = [String]()

        for i in 1...999 {
            intPicker.append(String(i))
        }
        intPickerData.append(intPicker)
        if self.frequency == Frequency.Daily {
            frequencyPicker.append("times per day")
        } else if self.frequency == Frequency.Weekly {
            frequencyPicker.append("times per week")
        } else {
            frequencyPicker.append("times per month")
        }
        intPickerData.append(frequencyPicker)
    }
    
}
