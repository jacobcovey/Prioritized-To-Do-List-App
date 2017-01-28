//
//  DayMonthYear.swift
//  Priorities
//
//  Created by Jacob Covey on 1/26/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import Foundation

class DayMonthYear: NSObject, NSCoding {
    var day: Int
    var month: Int
    var year: Int
    
    init(day: Int, month: Int, year: Int){
        self.day = day
        self.month = month
        self.year = year
    }
    
    required init?(coder aDecoder: NSCoder) {
        day = aDecoder.decodeInteger(forKey: "day")
        month = aDecoder.decodeInteger(forKey: "month")
        year = aDecoder.decodeInteger(forKey: "year")
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(day, forKey: "day")
        aCoder.encode(month, forKey: "month")
        aCoder.encode(year, forKey: "year")
    }
}
    
