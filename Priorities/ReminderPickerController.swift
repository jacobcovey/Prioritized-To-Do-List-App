//
//  ReminderPickerController.swift
//  Priorities
//
//  Created by Jacob Covey on 2/18/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class ReminderPickerController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var reminderSet: Bool?
    var repeate: Bool = false
    var frequency: Frequency?
    var pickerData = [[String]]()
    var componentWidth = [CGFloat]()
    
    @IBOutlet var repetitivePicker: UIPickerView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var reminderSpecificView: UIStackView!
    @IBOutlet var weeklyMonthlyView: UIStackView!
    @IBOutlet var frequencySegControl: UISegmentedControl!

    @IBAction func segControlAction(_ sender: Any) {
        if frequencySegControl.selectedSegmentIndex == 0 {
            weeklyMonthlyView.isHidden = true
            datePicker.isHidden = false
        } else if frequencySegControl.selectedSegmentIndex == 1 {
            weeklyMonthlyView.isHidden = false
            datePicker.isHidden = true
            loadCompenetWidth(isWeekly: true)
            loadPickerArrays(isWeekly: true)
            repetitivePicker.reloadAllComponents()
        } else if frequencySegControl.selectedSegmentIndex == 2 {
            weeklyMonthlyView.isHidden = false
            datePicker.isHidden = true
            loadCompenetWidth(isWeekly: false)
            loadPickerArrays(isWeekly: false)
            repetitivePicker.reloadAllComponents()
        }
    }
    
    @IBAction func save(_ sender: Any) {
        self.reminderSet = true
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        TaskBank.sharedInstance.reminderDate = nil
        TaskBank.sharedInstance.deleteReminder = true
        TaskBank.sharedInstance.cancelReminder = true
        self.reminderSet = false
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TaskBank.sharedInstance.deleteReminder = false
        self.loadCompenetWidth(isWeekly: true)
        self.loadPickerArrays(isWeekly: true)
        self.repetitivePicker.dataSource = self
        self.repetitivePicker.delegate = self
        navigationItem.title = "Reminder"
        if self.repeate == true {
            datePicker.datePickerMode = .time
            reminderSpecificView.isHidden = false
        }
        self.repetitivePicker.selectRow(7, inComponent: 1, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.reminderSet != nil {
                TaskBank.sharedInstance.reminderDateSet = self.reminderSet!
                if self.repeate == true {
                if frequencySegControl.selectedSegmentIndex == 0 {
                    TaskBank.sharedInstance.reminderDate = ReminderDate(date: datePicker.date, frequency: .Daily, type: .CheckOff, weekday: nil)
                } else if frequencySegControl.selectedSegmentIndex == 1 {
                    let hourMin = pickerData[1][repetitivePicker.selectedRow(inComponent: 1)] + ":" + pickerData[2][repetitivePicker.selectedRow(inComponent: 2)] + " " + pickerData[3][repetitivePicker.selectedRow(inComponent: 3)]
                    let date = Date(dateString: hourMin)
                    TaskBank.sharedInstance.reminderDate = ReminderDate(date: date, frequency: .Weekly, type: .CheckOff, weekday: repetitivePicker.selectedRow(inComponent: 0))
                } else if frequencySegControl.selectedSegmentIndex == 2 {
                    let hourMin = pickerData[1][repetitivePicker.selectedRow(inComponent: 1)] + ":" + pickerData[2][repetitivePicker.selectedRow(inComponent: 2)] + " " + pickerData[3][repetitivePicker.selectedRow(inComponent: 3)]
                    let date = Date(dateString: hourMin)
                    TaskBank.sharedInstance.reminderDate = ReminderDate(date: date, frequency: .Monthly, type: .CheckOff, weekday: repetitivePicker.selectedRow(inComponent: 0)+1)
                }
            } else {
            TaskBank.sharedInstance.reminderDate = ReminderDate(date: datePicker.date, frequency: .Once, type: .Once, weekday: nil)
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerData[component][row])
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return componentWidth[component]
    }
    
    func loadCompenetWidth(isWeekly: Bool) {
        self.componentWidth.removeAll()
        if isWeekly == true {
            self.componentWidth.append(145)
            self.componentWidth.append(45)
            self.componentWidth.append(45)
            self.componentWidth.append(45)
        } else {
            self.componentWidth.append(145)
            self.componentWidth.append(45)
            self.componentWidth.append(45)
            self.componentWidth.append(45)
        }
    }
    
    func loadPickerArrays(isWeekly: Bool) {
        pickerData.removeAll()
        var firstPicker = [String]()
        var hourPicker = [String]()
        var minPicker = [String]()
        var amPmPicker = [String]()
        if isWeekly == true {
            firstPicker.append("Sundays")
            firstPicker.append("Mondays")
            firstPicker.append("Tuesdays")
            firstPicker.append("Wednesdays")
            firstPicker.append("Thursdays")
            firstPicker.append("Fridays")
            firstPicker.append("Saturdays")
        } else {
            firstPicker.append("1st")
            firstPicker.append("2nd")
            firstPicker.append("3rd")
            firstPicker.append("4th")
            firstPicker.append("5th")
            firstPicker.append("6th")
            firstPicker.append("7th")
            firstPicker.append("8th")
            firstPicker.append("9th")
            firstPicker.append("10th")
            firstPicker.append("11th")
            firstPicker.append("12th")
            firstPicker.append("13th")
            firstPicker.append("14th")
            firstPicker.append("15th")
            firstPicker.append("16th")
            firstPicker.append("17th")
            firstPicker.append("18th")
            firstPicker.append("19th")
            firstPicker.append("20th")
            firstPicker.append("21th")
            firstPicker.append("22th")
            firstPicker.append("23th")
            firstPicker.append("24th")
            firstPicker.append("25th")
            firstPicker.append("26th")
            firstPicker.append("27th")
            firstPicker.append("28th")
        }
        pickerData.append(firstPicker)
        for i in 1...12 {
            hourPicker.append(String(i))
        }
        pickerData.append(hourPicker)
        minPicker.append("00")
        minPicker.append("01")
        minPicker.append("02")
        minPicker.append("03")
        minPicker.append("04")
        minPicker.append("05")
        minPicker.append("06")
        minPicker.append("07")
        minPicker.append("08")
        minPicker.append("09")
        for i in 10...59 {
            minPicker.append(String(i))
        }
        pickerData.append(minPicker)
        amPmPicker.append("AM")
        amPmPicker.append("PM")
        pickerData.append(amPmPicker)
    }
}

extension Date
{
    
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "hh:mm a"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)
    }
}

