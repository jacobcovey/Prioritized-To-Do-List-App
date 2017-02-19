//
//  ReminderDate.swift
//  Priorities
//
//  Created by Jacob Covey on 2/18/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import Foundation

class ReminderDate: NSObject, NSCoding {
    var type: TaskType
    var frequency: Frequency
    var weekday: Int?
    var date: Date
//    var reminderSet: Bool
    
    init(date: Date, frequency: Frequency, type: TaskType, weekday: Int?){
        self.date = date
        self.type = type
        self.frequency = frequency
        self.weekday = weekday
//        self.reminderSet = reminderSet
    }
    
    required init?(coder aDecoder: NSCoder) {
        date = aDecoder.decodeObject(forKey: "date") as! Date
//        frequency = aDecoder.decodeObject(forKey: "frequency") as! Frequency
        weekday = aDecoder.decodeObject(forKey: "weekday") as? Int
//        type = aDecoder.decodeObject(forKey: "type") as! TaskType
        frequency = Frequency(rawValue: aDecoder.decodeInteger(forKey: "frequency"))!
        type = TaskType(rawValue: aDecoder.decodeInteger(forKey: "type"))!
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(type.rawValue, forKey: "type")
        aCoder.encode(frequency.rawValue, forKey: "frequency")
        aCoder.encode(weekday, forKey: "weekday")
    }
}
