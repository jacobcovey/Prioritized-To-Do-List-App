//
//  AddTaskTimePickerController.swift
//  Priorities
//
//  Created by Jacob Covey on 3/2/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class AddTaskTimePickerController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet var timePicker: UIPickerView!
    
    var timePickerData = [[String]]()
    var newTime:HourMinSec = HourMinSec(hour: 0, min: 0, sec: 0)
    var componentWidth = [CGFloat]()
    var frequency: Frequency?
//    var oldTime:HourMinSec!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Goal Time"
        
        //        self.timePicker.selectRow(5, inComponent: 2, animated: false)
        self.loadPickerArrays()
        self.timePicker.dataSource = self
        self.timePicker.delegate = self
//        self.timePicker.selectRow(0, inComponent: 0, animated: true)
//        self.timePicker.selectRow(1, inComponent: 2, animated: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.newTime.hour = Int(timePickerData[0][timePicker.selectedRow(inComponent: 0)])!
        self.newTime.min = Int(timePickerData[2][timePicker.selectedRow(inComponent: 2)])!
        TaskBank.sharedInstance.goalTimeSet = true
        TaskBank.sharedInstance.goalTime = self.newTime
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if self.componentWidth.isEmpty {
            if UIDevice().type == .iPhone6plus || UIDevice().type == .iPhone6Splus || UIDevice().type == .iPhone7plus {
                self.componentWidth.append(40)
                self.componentWidth.append(70)
                self.componentWidth.append(40)
                self.componentWidth.append(170)
            } else {
                self.componentWidth.append(40)
                self.componentWidth.append(70)
                self.componentWidth.append(40)
                self.componentWidth.append(140)
            }

        }
        return componentWidth[component]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
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
        var minArr = [String]()
//        var freqArr = [String]()
        for i in 0...999 {
            hourPicker.append(String(i))
        }
        timePickerData.append(hourPicker)
        colonArr.append("hours")
        timePickerData.append(colonArr)
        for i in 0...59 {
            minPicker.append(String(i))
        }
        timePickerData.append(minPicker)
        if frequency == Frequency.Daily {
            if UIDevice().type == .iPhone6plus || UIDevice().type == .iPhone6Splus || UIDevice().type == .iPhone7plus {
                minArr.append("min per day")
            } else {
                minArr.append("min daily")
            }
        } else if frequency == Frequency.Weekly {
            if UIDevice().type == .iPhone6plus || UIDevice().type == .iPhone6Splus || UIDevice().type == .iPhone7plus  {
                    minArr.append("min per week")
            } else {
            minArr.append("min weekly")
            }
        } else if frequency == Frequency.Monthly {
            if UIDevice().type == .iPhone6plus || UIDevice().type == .iPhone6Splus || UIDevice().type == .iPhone7plus {
                minArr.append("min per month")
            } else {
            minArr.append("min monthly")
            }
        }
        timePickerData.append(minArr)
//        if frequency == Frequency.Daily {
//            freqArr.append("/day")
//        } else if frequency == Frequency.Weekly {
//            if UIDevice().type == .iPhone5 || UIDevice().type == .iPhone5C || UIDevice().type == .iPhone5S || UIDevice().type == .iPhoneSE {
//                    freqArr.append("/week")
//            } else {
//            freqArr.append("/week")
//            }
//        } else if frequency == Frequency.Monthly {
//            if UIDevice().type == .iPhone5 || UIDevice().type == .iPhone5C || UIDevice().type == .iPhone5S || UIDevice().type == .iPhoneSE {
//                freqArr.append("/mon")
//            } else {
//            freqArr.append("/month")
//            }
//        }
//        timePickerData.append(freqArr)
        
    }
    
}
