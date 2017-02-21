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
    
    var reminderDate: ReminderDate?
    var reminderDateSet: Bool = false
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
        if let archivedTasks = NSKeyedUnarchiver.unarchiveObject(withFile: taskArchiveURL.path) as? [[Task]] {
            taskArrays = archivedTasks
            self.updateClockedInOnOpen()
            if self.checkIfNewDate() {
                self.resetForNewDate()
            }
            self.currentId = self.findHighestTaskID()
        } else {
            taskArrays = [urgent_important, nonUrgent_important, urgent_nonImportant, nonUrgent_nonImportant, completed]
        }
    }
    
    func savedChanges() -> Bool {
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
//        let today = DayMonthYear(day: 5, month: 2, year: 2017)
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
//        let today = DayMonthYear(day: 5, month: 2, year: 2017)
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
                break
            }
            break
        }
    }
    
    func removeOneTimeCompletedTasks() {
        for arr in self.taskArrays {
            for task in arr {
                if task.type == TaskType.Once {
                        self.removeTaskFromBank(task: task)
                }
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
            TaskBank.sharedInstance.reminders.append(reminder)
            let delegate = UIApplication.shared.delegate as? AppDelegate
            delegate?.updateScheduledNotification()
        }
    }
    
    func updateReminders() {
        self.reminders.removeAll()
        var count = 0
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
