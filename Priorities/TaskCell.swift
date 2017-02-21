//
//  TaskCell.swift
//  Priorities
//
//  Created by Jacob Covey on 1/14/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var frequencyLabel: UILabel!
    @IBOutlet var currentLabel: UILabel!
    @IBOutlet var goalLabel: UILabel!
    @IBOutlet var iconButton: UIButton!
    var location = [Int]()
    @IBOutlet var iconView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.accessoryType = .disclosureIndicator
        nameLabel.adjustsFontForContentSizeCategory = true
        frequencyLabel.adjustsFontForContentSizeCategory = true
        currentLabel.adjustsFontForContentSizeCategory = true
        goalLabel.adjustsFontForContentSizeCategory = true
        iconButton.adjustsImageWhenDisabled = true
    }
    @IBAction func iconClicked(_ sender: Any) {
//        let task = TaskBank.sharedInstance.allTasks[iconButton.tag]
//        if task.type == TaskType.Time {
//            task.switchClocked()
//        } else {
//            task.currentInt = task.currentInt! + 1
//        }
    }
}
