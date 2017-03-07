//
//  TaskCell.swift
//  Priorities
//
//  Created by Jacob Covey on 1/14/17.
//  Copyright © 2017 Jacob Covey. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    
    
    @IBOutlet var nameView: UIStackView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var frequencyLabel: UILabel!
    @IBOutlet var currentLabel: UILabel!
    @IBOutlet var goalLabel: UILabel!
    @IBOutlet var iconButton: UIButton!
    var location = [Int]()
    @IBOutlet var iconView: UIView!
    @IBOutlet var repetitiveSpecificView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIDevice().type == .iPhone6 || UIDevice().type == .iPhone6S || UIDevice().type == .iPhone6plus || UIDevice().type == .iPhone6Splus || UIDevice().type == .iPhone7 || UIDevice().type == .iPhone7plus || UIDevice().type == .simulator {
            self.accessoryType = .disclosureIndicator
            
        }
        nameLabel.adjustsFontForContentSizeCategory = true
        frequencyLabel.adjustsFontForContentSizeCategory = true
        currentLabel.adjustsFontForContentSizeCategory = true
        goalLabel.adjustsFontForContentSizeCategory = true
        iconButton.adjustsImageWhenDisabled = true
    }
}
