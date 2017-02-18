//
//  Task.swift
//  Priorities
//
//  Created by Jacob Covey on 1/2/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import Foundation

enum Frequency: Int {
    case Daily = 0
    case Weekly = 1
    case Monthly = 2
    case Once = 3
}
enum TaskType: Int {
    case Time = 0
    case CheckOff = 1
    case Once = 2
}

class Task: NSObject, NSCoding {
    var taskId: Int
    override var hashValue: Int {
        return self.taskId
    }
    var title: String
    var urgent: Bool
    var important: Bool
    var lastDateUsed: Date
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
    var partialGaolInt: Int?
    var completed: Bool
    var lastUpdated: DayMonthYear?
    var nextAlarm: Date?
    

    init(title: String, urgent: Bool, important: Bool, frequency: Frequency, type: TaskType, goalTime: HourMinSec?, goalInt: Int?, nextAlarm: Date?) {
        self.taskId = TaskBank.sharedInstance.getAndUpdateId()
        self.completed = false
        self.title = title
        self.urgent = urgent
        self.important = important
        self.lastDateUsed = Date()
        self.frequency = frequency
        self.type = type
        self.goalTime = goalTime
        self.goalInt = goalInt
        self.nextAlarm = nextAlarm
        self.lastUpdated = Task.convertDateToDayMonthYear(date: Date())
        if type == .Time {
            currentTime = HourMinSec(hour: 0, min: 0, sec: 0)
            self.clockedIn = false
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
                    self.partialGaolInt = Int( Double(goalInt!) * percentage )
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
                    self.partialGaolInt = Int( Double(goalInt!) * percentage )
                } else if type == .Time{
                    let seconds = self.goalTime?.getTotalSeconds()
                    let partialSeconds: Int = Int( Double(seconds!) * percentage)
                    self.partialGoalTime = HourMinSec(hour: 0, min: 0, sec: 0)
                    self.partialGoalTime?.addSeconds(partialSeconds)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        taskId = aDecoder.decodeInteger(forKey: "taskId")
        title = aDecoder.decodeObject(forKey: "title") as! String
        urgent = aDecoder.decodeBool(forKey: "urgent")
        important = aDecoder.decodeBool(forKey: "important")
        lastDateUsed = aDecoder.decodeObject(forKey: "lastDateUsed") as! Date
        frequency = Frequency(rawValue: aDecoder.decodeInteger(forKey: "frequency"))!
        type = TaskType(rawValue: aDecoder.decodeInteger(forKey: "type"))!
        if type == TaskType.Time {
            goalTime = aDecoder.decodeObject(forKey: "goalTime") as? HourMinSec
            currentTime = aDecoder.decodeObject(forKey: "currentTime") as? HourMinSec
            clockedIn = aDecoder.decodeObject(forKey: "clockedIn") as? Bool
            partialGoalTime = aDecoder.decodeObject(forKey: "partialGoalTime") as? HourMinSec
        } else {
            goalInt = aDecoder.decodeObject(forKey: "goalInt") as? Int
            currentInt = aDecoder.decodeObject(forKey: "currentInt") as? Int
            partialGaolInt = aDecoder.decodeObject(forKey: "partialGoalInt") as? Int
        }
        partialFisrt = aDecoder.decodeBool(forKey: "partialFirst")
        completed = aDecoder.decodeBool(forKey: "completed")
        lastUpdated = aDecoder.decodeObject(forKey: "lastUpdated") as? DayMonthYear
        nextAlarm = aDecoder.decodeObject(forKey: "nextAlarm") as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(taskId, forKey: "taskId")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(urgent, forKey: "urgent")
        aCoder.encode(important, forKey: "important")
        aCoder.encode(lastDateUsed, forKey: "lastDateUsed")
        aCoder.encode(frequency.rawValue, forKey: "frequency")
        aCoder.encode(type.rawValue, forKey: "type")
        aCoder.encode(goalTime, forKey: "goalTime")
        aCoder.encode(currentTime, forKey: "currentTime")
        aCoder.encode(clockedIn, forKey: "clockedIn")
        aCoder.encode(goalInt, forKey: "goalInt")
        aCoder.encode(currentInt, forKey: "currentInt")
        aCoder.encode(partialFisrt, forKey: "partialFirst")
        aCoder.encode(partialGoalTime, forKey: "partialGoalTime")
        aCoder.encode(partialGaolInt, forKey: "partialGoalInt")
        aCoder.encode(completed, forKey: "completed")
        aCoder.encode(lastUpdated, forKey: "lastUpdated")
        aCoder.encode(nextAlarm, forKey: "nextAlarm")
        
    }
    
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
    
    func secondsCurrentLessThanGoal() -> Int {
        let diff = (self.goalTime?.getTotalSeconds())! - (self.currentTime?.getTotalSeconds())!
//        diff += ((self.goalTime?.hour)! - (self.currentTime?.hour)!) * 3600
//        diff += ((self.goalTime?.min)! - (self.currentTime?.min)!) * 60
//        diff += (self.goalTime?.sec)! - (self.currentTime?.sec)!
        return diff
    }
    
    static func convertDateToDayMonthYear(date: Date) -> DayMonthYear {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = NSTimeZone.local
        let localDate = dateFormatter.string(from: date)
        let dateComps = localDate.components(separatedBy: " ")
        let day = (dateComps[1].components(separatedBy: ","))[0]
        let year = (dateComps[2].components(separatedBy: ","))[0]
        var month = 0
        switch dateComps[0] {
        case "Jan":
            month = 1
        case "Feb":
            month = 2
        case "Mar":
            month = 3
        case "Apr":
            month = 4
        case "May":
            month = 5
        case "Jun":
            month = 6
        case "Jul":
            month = 7
        case "Aug":
            month = 8
        case "Spt":
            month = 9
        case "Oct":
            month = 10
        case "Nov":
            month = 11
        case "Dec":
            month = 12
        default:
            break
        }
        return DayMonthYear(day: Int(day)!, month: month, year: Int(year)!)
    }
    
    
}

func ==(lhs: Task, rhs: Task) -> Bool {
    return lhs.taskId == rhs.taskId
}
