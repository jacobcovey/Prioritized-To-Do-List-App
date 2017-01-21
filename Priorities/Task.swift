//
//  Task.swift
//  Priorities
//
//  Created by Jacob Covey on 1/2/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import Foundation

enum Frequency {
    case Daily
    case Weekly
    case Monthly
    case Once
}
enum TaskType {
    case Time
    case CheckOff
    case Once
}

class Task: NSObject {
    var taskId: Int
    override var hashValue: Int {
        return self.taskId
    }
    var title: String
    var urgent: Bool
    var important: Bool
    var dateCreated: Date
    var frequency: Frequency
    var type: TaskType
    var goalTime: HourMinSec?
    var currentTime: HourMinSec?
//    var autoClockOut: HourMinSec?
    var clockedIn: Bool?
    var goalInt: Int?
    var currentInt: Int?
    var partialFisrt: Bool
    var partialGoalTime: HourMinSec?
    var paritalGaolInt: Int?
    var completed: Bool
    var lastUpdated: Date?
    

    init(title: String, urgent: Bool, important: Bool, frequency: Frequency, type: TaskType, goalTime: HourMinSec?, goalInt: Int?) {
        self.taskId = TaskBank.sharedInstance.getAndUpdateId()
        self.completed = false
        self.title = title
        self.urgent = urgent
        self.important = important
        self.dateCreated = Date()
        self.frequency = frequency
        self.type = type
        self.goalTime = goalTime
        self.goalInt = goalInt
        if type == .Time {
            currentTime = HourMinSec(hour: 0, min: 0, sec: 0)
            self.clockedIn = false
            self.lastUpdated = Date()
        } else {// either checkOff or once
            currentInt = 0
        }
//        self.autoClockOut = autoClockOut
        // Check for partial first
        if type == .CheckOff && goalInt == 1 {
            self.partialFisrt = false
        } else {
            switch frequency {
            case .Daily:
                self.partialFisrt = false
            case .Once:
                self.partialFisrt = false
            case .Weekly:
                self.partialFisrt = true
                // calculate and assign the corrent portion of the goal
                let date = Date()
                let calendar = Calendar.current
                let weekDay = calendar.component(.weekday, from: date)
                let percentage: Double = 1 - (Double(weekDay - 1) / 7)
                if type == .CheckOff {
                    self.paritalGaolInt = Int( Double(goalInt!) * percentage )
                } else if type == .Time {
                    let seconds = self.goalTime?.getTotalSeconds()
                    let partialSeconds: Int = Int( Double(seconds!) * percentage)
                    self.partialGoalTime = HourMinSec(hour: 0, min: 0, sec: 0)
                    self.partialGoalTime?.addSeconds(partialSeconds)
                }
            case .Monthly:
                self.partialFisrt = true
                // calculate and assign the corrent portion of the goal
                let date = Date()
                let calendar = Calendar.current
                let day = calendar.component(.day, from: date)
                let interval = calendar.dateInterval(of: .month, for: date)!
                let daysInMonth = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
                let percentage: Double = 1 - (Double(day) - 1 / Double(daysInMonth))
                if type == .CheckOff {
                    self.paritalGaolInt = Int( Double(goalInt!) * percentage )
                } else if type == .Time{
                    let seconds = self.goalTime?.getTotalSeconds()
                    let partialSeconds: Int = Int( Double(seconds!) * percentage)
                    self.partialGoalTime = HourMinSec(hour: 0, min: 0, sec: 0)
                    self.partialGoalTime?.addSeconds(partialSeconds)
                }
            }
        }
    }
    
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(taskId, forKey: "taskId")
//        aCoder.encode(hashValue, forKey: "hashValue")
//        aCoder.encode(title, forKey: "title")
//        aCoder.encode(urgent, forkey: "urgent")
//        aCoder.encode(important, forkey: "important")
//        aCoder.encode(dateCreated, forKey: "dateCreated")
//        aCoder.encode(frequency, forKey: "frequency")
//        aCoder.encode(type, forKey: "type")
//        aCoder.encode(goalTime, forKey: "goalTime")
//        aCoder.encode(currentTime, forKey: "currentTime")
        
//    }
    
    func updateCompleted() {
        if self.type == .Time {
            if (self.currentTime?.getTotalSeconds())! >= (self.goalTime?.getTotalSeconds())! {
                self.completed = true
            }
        } else { // checkOff or once
            if self.currentInt! >= self.goalInt!{
                self.completed = true
            }
        }
    }
    
    func switchClocked() {
        if self.clockedIn == true {
            self.clockedIn = false
        } else if self.clockedIn == false {
            self.clockedIn = true
        }
    }
}

func ==(lhs: Task, rhs: Task) -> Bool {
    return lhs.taskId == rhs.taskId
}
