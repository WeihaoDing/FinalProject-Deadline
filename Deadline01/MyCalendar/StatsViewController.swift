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
    public var inprogress = 200
    
    public var finished = 10
    
    public var overdue = 20
    
    
    @IBOutlet weak var progressStack: UIStackView!

    @IBOutlet weak var overdueBarWidth: NSLayoutConstraint!

    @IBOutlet weak var inprogressBarWidth: NSLayoutConstraint!
    @IBOutlet weak var finishedBarWidth: NSLayoutConstraint!
    @IBOutlet weak var finishedLabel: UILabel!
    @IBOutlet weak var overdueLabel: UILabel!
    @IBOutlet weak var inprogressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //overdue should automaticly adjust width
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let totalTask = inprogress + finished + overdue
        let length = progressStack.frame.width
        finishedBarWidth.constant = CGFloat(Float(length) * (Float(finished) / Float(totalTask)))
        inprogressBarWidth.constant = CGFloat(Float(length) * (Float(inprogress) / Float(totalTask)))
        overdueBarWidth.constant = CGFloat(Float(length) * (Float(overdue) / Float(totalTask)))
        
        finishedLabel.text = finished.description
        overdueLabel.text = overdue.description
        inprogressLabel.text = inprogress.description
        
        progressStack.layer.masksToBounds = true
        progressStack.layer.cornerRadius = CGFloat(30)
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

