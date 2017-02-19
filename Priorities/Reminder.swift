//
//  Reminder.swift
//  Priorities
//
//  Created by Jacob Covey on 2/11/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import Foundation

import Foundation

class Reminder: NSObject, NSCoding {
    var reminderDate: ReminderDate
    var title: String
    var message: String
    var id: String
    
    init(reminderDate: ReminderDate, title: String, message: String, id: String){
        self.reminderDate = reminderDate
        self.title = title
        self.message = message
        self.id = id
    }
    
    required init?(coder aDecoder: NSCoder) {
        reminderDate = aDecoder.decodeObject(forKey: "reminderDate") as! ReminderDate
        title = aDecoder.decodeObject(forKey: "title") as! String
        message = aDecoder.decodeObject(forKey: "message") as! String
        id = aDecoder.decodeObject(forKey: "id") as! String
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(reminderDate, forKey: "reminderDate")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(message, forKey: "message")
        aCoder.encode(id, forKey: "id")
    }
    
}
