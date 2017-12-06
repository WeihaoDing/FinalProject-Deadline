//
//  CollectionViewCell.swift
//  MyCalendar
//
//  Created by Xinyi Wang on 11/28/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CollectionViewCell: JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventIndicator: UIView!
    
    public var dueEvent: Due = Due()
    public var segueTo: UIStoryboardSegue!
    public var date: String = ""
    
    // Initializer
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public struct Due {
    public var subject: String
    public var color: UIColor
    public var content: String
    // conversion between Date and String?
    public var deadline: String
    // 1 (urgent) --- 10
    public var emergence: Int
    
    init() {
        subject = ""
        color = UIColor.white
        content = ""
        deadline = ""
        emergence = 10
    }
    
    init(subject: String, color: UIColor, content: String, deadline: String, emergence: Int) {
        self.subject = subject
        self.color = color
        self.content = content
        self.deadline = deadline
        self.emergence = emergence
    }
}
