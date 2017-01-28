//
//  HourMinSec.swift
//  Priorities
//
//  Created by Jacob Covey on 1/2/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import Foundation

class HourMinSec: NSObject, NSCoding {
    var hour: Int
    var min: Int
    var sec: Int
    
    init(hour: Int, min: Int, sec: Int){
        self.hour = hour
        self.min = min
        self.sec = sec
    }

    required init?(coder aDecoder: NSCoder) {
        hour = aDecoder.decodeInteger(forKey: "hour")
        min = aDecoder.decodeInteger(forKey: "min")
        sec = aDecoder.decodeInteger(forKey: "sec")
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(hour, forKey: "hour")
        aCoder.encode(min, forKey: "min")
        aCoder.encode(sec, forKey: "sec")
    }
    
    func addSeconds(_ seconds: Int){
        var minutes: Int = 0
        var hour: Int = 0
        self.sec += seconds
        if self.sec > 59 {
            minutes = self.sec / 60
            self.sec = self.sec - (minutes * 60)
            self.min += minutes
        }
        if self.min > 59 {
            hour = self.min / 60
            self.min = self.min - (hour * 60)
            self.hour += hour
        }
    }
    
    func getTotalSeconds() -> Int {
        return (((self.hour * 60) + self.min) * 60) + self.sec
    }
    
    func toStringWithSec() -> String {
        return String(self.hour) + ":" + String(format: "%02d", self.min) + "." + String(format: "%02d", self.sec)
    }
    
    func toStringWOsec() -> String {
        return String(self.hour) + ":" + String(format: "%02d",self.min)
    }
}
