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
//    var urgent_important = Set<Task> ()
//    var nonUrgent_important = Set<Task>()
//    var urgent_nonImportant = Set<Task>()
//    var nonUrgent_nonImportant = Set<Task>()
//    var completed = Set<Task>()
//    var taskSets = [Set<Task>]()
//    var setNames = ["Important & Urgent", "Important & Nonurgent", "Nonimportant & Urgent", "NonImportant & Nonurgent", "Completed"]
    
    var urgent_important = [Task]()
    var nonUrgent_important = [Task]()
    var urgent_nonImportant = [Task]()
    var nonUrgent_nonImportant = [Task]()
    var completed = [Task]()
    var allTasks = [Task]()
    var taskArrays = [[Task]]()
    var arrayNames = ["Important & Urgent", "Important & Nonurgent", "Nonimportant & Urgent", "NonImportant & Nonurgent", "Completed"]
    
    init() {
//        taskSets = [urgent_important, nonUrgent_important, urgent_nonImportant, nonUrgent_nonImportant, completed]
        taskArrays = [urgent_important, nonUrgent_important, urgent_nonImportant, nonUrgent_nonImportant, completed]
    }
    
    func orginizeTasks() {
        for task in allTasks {
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
    
    func doesExistInCompletedArray(task: Task) -> Bool {
        for tsk in taskArrays[4] {
            if tsk.taskId == task.taskId {
                return true
            }
        }
        return false
    }
    
    func getAndUpdateId() ->Int {
        currentId += 1
        return currentId
    }
    
}
