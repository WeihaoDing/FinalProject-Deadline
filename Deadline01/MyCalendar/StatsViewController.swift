//
//  StatsViewController.swift
//  MyCalendar
//
//  Created by Xinyi Wang on 12/5/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {
    
    //need to be populized, from icloud or other views..
    public var inprogress = 20
    
    public var finished = 10
    
    public var overdue = 20
    
    
    @IBOutlet weak var progressStack: UIStackView!
    @IBOutlet weak var finishedBar: UIView!
    @IBOutlet weak var inprogressBar: UIView!
    @IBOutlet weak var overdueBar: UIView!
    @IBOutlet weak var inprogressLabel: UILabel!
    
    @IBOutlet weak var finishedLabel: UILabel!
    @IBOutlet weak var overdueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //overdue should automaticly adjust width
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let totalTask = inprogress + finished + overdue
        let length = progressStack.frame.width
        finishedBar.frame.size.width = CGFloat(Float(length) * (Float(finished) / Float(totalTask)))
        inprogressBar.frame.size.width = CGFloat(Float(length) * (Float(inprogress) / Float(totalTask)))
        overdueBar.frame.size.width = CGFloat(Float(length) * (Float(overdue) / Float(totalTask)))
        self.view.setNeedsLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

