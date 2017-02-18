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
    var date: Date
    var title: String
    var message: String
    var id: String
    
    init(date: Date, title: String, message: String, id: String){
        self.date = date
        self.title = title
        self.message = message
        self.id = id
    }
    
    required init?(coder aDecoder: NSCoder) {
        date = aDecoder.decodeObject(forKey: "date") as! Date
        title = aDecoder.decodeObject(forKey: "title") as! String
        message = aDecoder.decodeObject(forKey: "message") as! String
        id = aDecoder.decodeObject(forKey: "id") as! String
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(message, forKey: "message")
        aCoder.encode(id, forKey: "id")
    }
    
}
