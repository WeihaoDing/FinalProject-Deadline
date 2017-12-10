//
//  DateDetailViewController.swift
//  MyCalendar
//
//  Created by Xinyi Wang on 11/29/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit

class DateDetailViewController: UIViewController {
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var completeIndicator: UIView!
    @IBOutlet weak var subjectTitle: UILabel!
    @IBOutlet weak var dueColor: UIView!
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var deadlineTitle: UILabel!
    @IBOutlet weak var emergenceTitle: UILabel!
    

    
    // How to deal with multiple dues???
    public var detail: Due = Due.init()
    public var formattedDate: String = ""
    
    public var lastView: String = ""
    
    private var mainViewController: ViewController!
    private var listViewController: ListViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLayout()
        
        mainBuilder()
        listBuilder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        // to lastView
        
        print(lastView)
        
        if lastView == "mainCalendar" {
            self.performSegue(withIdentifier: "unwindToCalendar", sender: nil)
        } else if lastView == "listView" {
            self.performSegue(withIdentifier: "unwindToList", sender: nil)
        }

    }
    
    private func setUpLayout() {
        dueColor.layer.cornerRadius = dueColor.frame.width / 2
        completeIndicator.layer.cornerRadius = completeIndicator.frame.width / 2
        
        dateTitle.text = formattedDate
        subjectTitle.text = detail.subject
        dueColor.backgroundColor = detail.color
        contentTitle.text = detail.content
        deadlineTitle.text = detail.deadline
        emergenceTitle.text = String.init(detail.emergence)
    }
    
    private func mainBuilder() {
        if mainViewController == nil {
            mainViewController = storyboard?.instantiateViewController(withIdentifier: "mainCalendar") as! ViewController
        }
    }
    
    private func listBuilder() {
        if listViewController == nil {
            listViewController = storyboard?.instantiateViewController(withIdentifier: "listView") as! ListViewController
        }
    }
}
