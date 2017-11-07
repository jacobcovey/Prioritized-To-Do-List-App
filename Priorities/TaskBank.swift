//
//  TaskBank.swift
//  Priorities
//
//  Created by Jacob Covey on 1/2/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class TaskBank {
    
    static let sharedInstance = TaskBank()
    
    var currentId: Int = 0
    
    var phoneType: Model
    var reminderDate: ReminderDate?
    var cancelReminder: Bool = false
    var firstTime: Bool = true
    var reminderDateSet: Bool = false
    var goalTimeSet: Bool = false
    var goalTime: HourMinSec?
    var goalIntSet: Bool = false
    var goalInt: Int?
    var notes: String?
    var notesSet: Bool = false
    var deleteReminder: Bool = false
    var reminders = [Reminder]()
    var urgent_important = [Task]()
    var nonUrgent_important = [Task]()
    var urgent_nonImportant = [Task]()
    var nonUrgent_nonImportant = [Task]()
    var completed = [Task]()
    var allTasks = [Task]()
    var taskArrays = [[Task]]()
    var arrayNames = ["Important & Urgent", "Important", "Urgent", "To-do", "Completed"]
    let taskArchiveURL: URL = {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("tasks.archive")
    }()

    init() {
        self.phoneType = UIDevice().type
        if let archivedTasks = NSKeyedUnarchiver.unarchiveObject(withFile: taskArchiveURL.path) as? [[Task]] {
            taskArrays = archivedTasks
            self.updateClockedInOnOpen()
            if self.checkIfNewDate() {
                self.resetForNewDate()
            }
            self.setTasksLastUpdated()
            self.currentId = self.findHighestTaskID()
        } else {
            taskArrays = [urgent_important, nonUrgent_important, urgent_nonImportant, nonUrgent_nonImportant, completed]
        }
    }
    
    func savedChanges() -> Bool {
        if self.checkIfNewDate() {
            self.resetForNewDate()
        }
        self.setTasksLastUpdated()
        print("Saving items to: \(taskArchiveURL.path)")
        return NSKeyedArchiver.archiveRootObject(taskArrays, toFile: taskArchiveURL.path)
    }
    
    func updateClockedInOnOpen() {
        for arr in taskArrays {
            for task in arr {
                if task.type == TaskType.Time && task.clockedIn == true {
                    let elapsed = Date().timeIntervalSince(task.lastDateUsed)
                    let duration = Int(elapsed)
                    task.currentTime?.addSeconds(duration)
                }
            }
        }
    }
    
    func setAllTimedToClockedOut() {
        for arr in taskArrays {
            for task in arr {
                if task.type == TaskType.Time && task.clockedIn == true {
                    task.clockedIn = false
                }
            }
        }
    }
    
    func setTasksLastUpdated() {
        for arr in taskArrays {
            for task in arr {
                task.lastUpdated = Task.convertDateToDayMonthYear(date: Date())
                task.lastDateUsed = Date()
            }
        }
    }
    
    func addSecToAllTimedTasks(seconds: Int) {
        for arr in self.taskArrays {
            for task in arr {
                if task.type == TaskType.Time && task.clockedIn == true {
                    task.currentTime?.addSeconds(seconds)
                }
            }
        }
    }
    
    func checkIfNewDate() -> Bool {
        let today = Task.convertDateToDayMonthYear(date: Date())
//        let today = DayMonthYear(day: 6, month: 3, year: 2017)
        if !self.taskBankIsEmpty() {
            for arr in self.taskArrays {
                for task in arr {
                    if today.month != task.lastUpdated?.month || today.day != task.lastUpdated?.day {
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
        return false
    }
    
    func resetForNewDate() {
        let today = Task.convertDateToDayMonthYear(date: Date())
//        let today = DayMonthYear(day: 6, month: 3, year: 2017)
        for arr in self.taskArrays {
            for task in arr {
                if today.month != task.lastUpdated?.month || today.day != task.lastUpdated?.day {
                    self.removeOneTimeCompletedTasks()
                    self.resetTasks(frequency: Frequency.Daily.rawValue)
                    if self.isNewWeek(today: today, task: task) {
                        self.resetTasks(frequency: Frequency.Weekly.rawValue)
                    }
                    if today.month != task.lastUpdated?.month || today.year != task.lastUpdated?.year {
                        self.resetTasks(frequency: Frequency.Monthly.rawValue)
                    }
                }
            }
        }
    }
    
    func removeOneTimeCompletedTasks() {
        let arr = self.taskArrays[4]
        for task in arr {
            if task.type == TaskType.Once {
                    self.removeTaskFromBank(task: task)
            }
        }
    }
    
    func isNewWeek(today: DayMonthYear, task: Task) -> Bool {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        components.day = today.day
        components.month = today.month
        components.year = today.year
        let todayDate = calendar.date(from: components)
        
        var taskComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        taskComponents.day = task.lastUpdated?.day
        taskComponents.month = task.lastUpdated?.month
        taskComponents.year = task.lastUpdated?.year
        let lastUpdated = calendar.date(from: taskComponents)
        
        return calendar.component(.weekOfYear, from: todayDate!) != calendar.component(.weekOfYear, from: lastUpdated!)
    }
    
    func resetTasks(frequency: Int) {
        var index = 0
        for arr in self.taskArrays {
            for task in arr {
                if task.frequency == Frequency(rawValue: frequency) {
                    if task.type == TaskType.Time {
                        task.currentTime = HourMinSec(hour: 0, min: 0, sec: 0)
                    } else if task.type == TaskType.CheckOff {
                        task.currentInt = 0
                    }
                    if index == 4 {
                        self.addTaskToBank(task: task)
                        taskArrays[4] = taskArrays[4].filter{$0 != task}
                    }
                }
            }
            index += 1
        }
    }
    
    func findHighestTaskID() -> Int {
        var high = 0
        for arr in self.taskArrays {
            for task in arr {
                if task.taskId > high {
                    high = task.taskId
                }
            }
        }
        return high
    }
    
    
    func addTaskToBank(task: Task) {
        if task.important == true && task.urgent == true {
            taskArrays[0].append(task)
        } else if task.important == true && task.urgent == false {
            taskArrays[1].append(task)
        } else if task.important == false && task.urgent == true {
            taskArrays[2].append(task)
        } else if task.important == false && task.urgent == false {
            taskArrays[3].append(task)
        }
        if task.reminderDate != nil {
            let message = "Reminder for task: \"\(task.title)\""
            let title = "Task Reminder"

            let reminder = Reminder(reminderDate: task.reminderDate!, title: title, message: message, id: String(task.taskId))
//            TaskBank.sharedInstance.reminders.append(reminder)
            self.reminders.append(reminder)
            
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.updateScheduledNotification()
        }
    }
    
    func updateReminders() {
        self.reminders.removeAll()
        for arr in self.taskArrays {
            for task in arr {
                if task.reminderDate != nil {
                    if task.reminderDate?.frequency == Frequency.Once {
                        if (task.reminderDate?.date)! > Date() {
                            let message = "Reminder for task: \"\(task.title)\""
                            let title = "Task Reminder"
                            
                            let reminder = Reminder(reminderDate: task.reminderDate!, title: title, message: message, id: String(task.taskId))
                            TaskBank.sharedInstance.reminders.append(reminder)
                        } else {
                         task.reminderDate = nil
                        }
                    } else if task.reminderDate?.frequency == Frequency.Daily {
                        let message = "Daily Reminder for task: \"\(task.title)\""
                        let title = "Task Reminder"
                        
                        let reminder = Reminder(reminderDate: task.reminderDate!, title: title, message: message, id: String(task.taskId))
                        TaskBank.sharedInstance.reminders.append(reminder)
                    } else if task.reminderDate?.frequency == Frequency.Weekly {
                        let message = "Weekly Reminder for task: \"\(task.title)\""
                        let title = "Task Reminder"
                        
                        let reminder = Reminder(reminderDate: task.reminderDate!, title: title, message: message, id: String(task.taskId))
                        TaskBank.sharedInstance.reminders.append(reminder)
                    } else if task.reminderDate?.frequency == Frequency.Monthly {
                        let message = "Monthly for task: \"\(task.title)\""
                        let title = "Task Reminder"
                        
                        let reminder = Reminder(reminderDate: task.reminderDate!, title: title, message: message, id: String(task.taskId))
                        TaskBank.sharedInstance.reminders.append(reminder)
                    }
                }
            }
        }
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.updateScheduledNotification()
    }
    
    func removeAlarmWithId(id: String) {
        for reminder in self.reminders {
            if reminder.id == id {
                self.reminders = self.reminders.filter{$0 != reminder}
                print("Reminder deleted. Number of reminders: " + String(self.reminders.count))
            }
        }
    }
    
    func moveTaskToCompleted(task: Task) {
        if !doesExistInCompletedArray(task: task){
            taskArrays[4].append(task)
            if task.important == true && task.urgent == true {
                taskArrays[0] = taskArrays[0].filter{$0 != task}
            } else if task.important == true && task.urgent == false {
              taskArrays[1] = taskArrays[1].filter{$0 != task}
            } else if task.important == false && task.urgent == true {
              taskArrays[2] = taskArrays[2].filter{$0 != task}
            } else if task.important == false && task.urgent == false {
              taskArrays[3] = taskArrays[3].filter{$0 != task}
          }
        }
    }
    
    func removeTaskFromBank(task: Task) {
        if doesExistInCompletedArray(task: task){
            taskArrays[4] = taskArrays[4].filter{$0 != task}
        }
        if task.important == true && task.urgent == true {
            taskArrays[0] = taskArrays[0].filter{$0 != task}
        } else if task.important == true && task.urgent == false {
            taskArrays[1] = taskArrays[1].filter{$0 != task}
        } else if task.important == false && task.urgent == true {
            taskArrays[2] = taskArrays[2].filter{$0 != task}
        } else if task.important == false && task.urgent == false {
            taskArrays[3] = taskArrays[3].filter{$0 != task}
        }
        self.removeAlarmWithId(id: String(task.taskId))
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.updateScheduledNotification()
    }
    
    func doesExistInCompletedArray(task: Task) -> Bool {
        for tsk in taskArrays[4] {
            if tsk.taskId == task.taskId {
                return true
            }
        }
        return false
    }
    
    func taskBankIsEmpty() -> Bool {
        for arr in self.taskArrays {
            if arr.count != 0 {
                return false
            }
        }
        return true
    }
    
    func getAndUpdateId() ->Int {
        currentId += 1
        return currentId
    }
    
}

func convertNumToWeekday(num: Int)->String {
    var day = ""
    switch num {
    case 0 :
        day = "Sundays"
    case 1 :
        day = "Mondays"
    case 2 :
        day = "Tuesdays"
    case 3 :
        day = "Wednesdays"
    case 4 :
        day = "Thursdays"
    case 5 :
        day = "Fridays"
    case 6 :
        day = "Saturdays"
    default:
        day = "Error"
    }
    return day
}

public enum Model : String {
    case simulator = "simulator/sandbox",
    iPod1          = "iPod 1",
    iPod2          = "iPod 2",
    iPod3          = "iPod 3",
    iPod4          = "iPod 4",
    iPod5          = "iPod 5",
    iPad2          = "iPad 2",
    iPad3          = "iPad 3",
    iPad4          = "iPad 4",
    iPhone4        = "iPhone 4",
    iPhone4S       = "iPhone 4S",
    iPhone5        = "iPhone 5",
    iPhone5S       = "iPhone 5S",
    iPhone5C       = "iPhone 5C",
    iPadMini1      = "iPad Mini 1",
    iPadMini2      = "iPad Mini 2",
    iPadMini3      = "iPad Mini 3",
    iPadAir1       = "iPad Air 1",
    iPadAir2       = "iPad Air 2",
    iPhone6        = "iPhone 6",
    iPhone6plus    = "iPhone 6 Plus",
    iPhone6S       = "iPhone 6S",
    iPhone6Splus   = "iPhone 6S Plus",
    iPhoneSE       = "iPhone SE",
    iPhone7        = "iPhone 7",
    iPhone7plus    = "iPhone 7 Plus",
    unrecognized   = "?unrecognized?"
}

public extension UIDevice {
    public var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
                
            }
        }
        var modelMap : [ String : Model ] = [
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            "iPod1,1"   : .iPod1,
            "iPod2,1"   : .iPod2,
            "iPod3,1"   : .iPod3,
            "iPod4,1"   : .iPod4,
            "iPod5,1"   : .iPod5,
            "iPad2,1"   : .iPad2,
            "iPad2,2"   : .iPad2,
            "iPad2,3"   : .iPad2,
            "iPad2,4"   : .iPad2,
            "iPad2,5"   : .iPadMini1,
            "iPad2,6"   : .iPadMini1,
            "iPad2,7"   : .iPadMini1,
            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPad3,1"   : .iPad3,
            "iPad3,2"   : .iPad3,
            "iPad3,3"   : .iPad3,
            "iPad3,4"   : .iPad4,
            "iPad3,5"   : .iPad4,
            "iPad3,6"   : .iPad4,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPad4,1"   : .iPadAir1,
            "iPad4,2"   : .iPadAir2,
            "iPad4,4"   : .iPadMini2,
            "iPad4,5"   : .iPadMini2,
            "iPad4,6"   : .iPadMini2,
            "iPad4,7"   : .iPadMini3,
            "iPad4,8"   : .iPadMini3,
            "iPad4,9"   : .iPadMini3,
            "iPhone7,1" : .iPhone6plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6Splus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone7,
            "iPhone9,2" : .iPhone7plus,
            "iPhone9,3" : .iPhone7,
            "iPhone9,4" : .iPhone7plus,
            ]
        
        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            return model
        }
        return Model.unrecognized
    }
    
}
