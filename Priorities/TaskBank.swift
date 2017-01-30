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
    
    var urgent_important = [Task]()
    var nonUrgent_important = [Task]()
    var urgent_nonImportant = [Task]()
    var nonUrgent_nonImportant = [Task]()
    var completed = [Task]()
    var allTasks = [Task]()
    var taskArrays = [[Task]]()
    var arrayNames = ["Important & Urgent", "Important & Not Urgent", "Not Important & Urgent", "Not Important & Not Urgent", "Completed"]
    let taskArchiveURL: URL = {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("tasks.archive")
    }()

    init() {
        if let archivedTasks = NSKeyedUnarchiver.unarchiveObject(withFile: taskArchiveURL.path) as? [[Task]] {
            taskArrays = archivedTasks
            self.setAllTimedToClockedOut()
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
//        let today = DayMonthYear(day: 1, month: 2, year: 2017)
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
//        let today = DayMonthYear(day: 1, month: 2, year: 2017)
        for arr in self.taskArrays {
            for task in arr {
                if today.month != task.lastUpdated?.month || today.day != task.lastUpdated?.day {
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
    
//    func orginizeTasks() {
//        for task in allTasks {
//            if task.important == true && task.urgent == true {
//                taskArrays[0].append(task)
//            } else if task.important == true && task.urgent == false {
//                taskArrays[1].append(task)
//            } else if task.important == false && task.urgent == true {
//                taskArrays[2].append(task)
//            } else if task.important == false && task.urgent == false {
//                taskArrays[3].append(task)
//            }
//        }
//    }
    
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
