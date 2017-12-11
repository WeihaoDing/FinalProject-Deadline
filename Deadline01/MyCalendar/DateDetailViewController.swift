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

    @IBOutlet weak var dueColor: UIButton!
    @IBOutlet weak var subject: UITextField!
    
    @IBOutlet weak var colorPicker: UIStackView!
    @IBOutlet weak var content: UITextField!
    
    @IBOutlet weak var emergence: UISlider!
    @IBOutlet weak var deadline: UIButton!
    

    public var detail: Due = Due.init()
    public var formattedDate: String = ""
    
    public var lastView: String = ""
    
    @IBAction func colorPicked(_ sender: UIButton) {
        colorPicker.isHidden = true
        let selectedColor = sender.backgroundColor!
        dueColor.setBackgroundImage(imageFromColor(color: selectedColor), for: .normal)
        
    }
    
    @IBAction func colorClicked(_ sender: Any) {
        colorPicker.isHidden = !colorPicker.isHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DETAIL")
        print(detail.toJSON()!)
        print(formattedDate)
        subject.isEnabled = false
        content.isEnabled = false
        deadline.isEnabled = false
        emergence.isEnabled = false
        dueColor.isEnabled = false
        colorPicker.isHidden = true
        setUpLayout()
    }
    
    @IBAction func editClicked(_ sender: UIButton) {
        if sender.title(for: .normal) == "Edit" {
            subject.isEnabled = true
            content.isEnabled = true
            deadline.isEnabled = true
            emergence.isEnabled = true
            dueColor.isEnabled = true

            sender.setTitle("Done", for: .normal)
        }else if sender.title(for: .normal) == "Done" {
            
            // Need better error handling
            
            if (dueColor.backgroundColor != nil && content.text != nil &&
                deadline.currentTitle != nil && subject.text != nil){
                
                detail.color = dueColor.backgroundColor!
                detail.content = content.text!
                detail.deadline = deadline.currentTitle!
                
                //not sure how emergence is converted
                detail.emergence = Int(emergence.value)
                
                detail.subject = subject.text!
            
                subject.isEnabled = false
                content.isEnabled = false
                deadline.isEnabled = false
                dueColor.isEnabled = false
                emergence.isEnabled = false
                sender.setTitle("Edit", for: .normal)
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        if lastView == "mainCalendar" {
            self.performSegue(withIdentifier: "unwindToCalendar", sender: nil)
        } else if lastView == "listView" {
            self.performSegue(withIdentifier: "unwindToList", sender: nil)
        } else {
            self.performSegue(withIdentifier: "unwindToMultiple", sender: nil)
        }
    }
    
    private func setUpLayout() {
        dueColor.layer.cornerRadius = dueColor.frame.width / 2
        completeIndicator.layer.cornerRadius = completeIndicator.frame.width / 2
        
        dateTitle.text = formattedDate
        subject.text = detail.subject
        dueColor.backgroundColor = detail.color
        content.text = detail.content
        deadline.setTitle(detail.deadline, for: .normal)
        emergence.value = Float(detail.emergence)
    }
    
    private func imageFromColor(color: UIColor) -> UIImage
    {
        let rect = CGRect.init(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}
