//
//  DateDetailViewController.swift
//  MyCalendar
//
//  Created by Xinyi Wang on 11/29/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit
import CloudKit

class DateDetailViewController: UIViewController {
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var completeIndicator: UIButton!

    @IBOutlet weak var dueColor: UIButton!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var colorPicker: UIStackView!
    @IBOutlet weak var content: UITextField!
    @IBOutlet weak var deadline: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var emergence: UISlider!
    
    public var detail: Due = Due.init()
    public var lastIndex: Int = 0

    public var formattedDate: String = ""
    public var lastView: String = ""
    private var selectedDate = Date()
    private var selectedColor: UIColor = UIColor.white
    private var completedTF: Bool = false
    private var completeColor: UIImage = UIImage.init()
    private var uncompleteColor: UIImage = UIImage.init()
    
    // DATABASE SHOULD BE PRIVATE
    let database = CKContainer.default().publicCloudDatabase
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        completeColor = imageFromColor(color: UIColor(red:0.36, green:0.72, blue:0.36, alpha:1.0))
        uncompleteColor = imageFromColor(color: UIColor(red:0.83, green:0.24, blue:0.36, alpha:1.0))
        subject.isEnabled = false
        content.isEnabled = false
        deadline.isEnabled = false
        emergence.isEnabled = false
        dueColor.isEnabled = false
        datePicker.isHidden = true
        colorPicker.isHidden = true
        setUpLayout()
    }
    
    // Dismisses the keyboard if needed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func editClicked(_ sender: UIButton) {
        if sender.title(for: .normal) == "Edit" {
            subject.isEnabled = true
            content.isEnabled = true
            deadline.isEnabled = true
            emergence.isEnabled = true
            dueColor.isEnabled = true
            sender.setTitle("Done", for: .normal)
        } else if sender.title(for: .normal) == "Done" {

            editDone()
            sender.setTitle("Edit", for: .normal)
            // fetch the old record from cloud
            //            let predicate = NSPredicate(format: "recordName == %@", detail.recordName)
            //            let query = CKQuery(recordType: "Due", predicate: predicate)
            //            database.perform(query, inZoneWith: nil) { (records, error) in
            //
            //            }
            let colorArrTemp = selectedColor.components
            let colorArr = [colorArrTemp.red, colorArrTemp.green, colorArrTemp.blue]
            let recordID = CKRecordID(recordName: detail.recordName)
            database.fetch(withRecordID: recordID) { record, error in
                if let myRecord = record, error == nil {
                    myRecord.setValue(self.detail.subject, forKey: "subject")
                    myRecord.setValue(colorArr, forKey: "color")
                    myRecord.setValue(self.detail.content, forKey: "content")
                    myRecord.setValue(self.detail.deadline, forKey: "deadline")
                    myRecord.setValue(self.detail.emergence, forKey: "priority")
                    myRecord.setValue(self.detail.completed, forKey: "completed")
                    self.database.save(myRecord, completionHandler: {returnedRecord, error in
                        if error != nil {
                            print("ERROR IN MODIFY: \(String(describing: error))")
                        } else {
                            print("MODIFY SUCCESS")
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func colorPicked(_ sender: UIButton) {
        colorPicker.isHidden = true
        selectedColor = sender.backgroundColor!
        dueColor.setBackgroundImage(imageFromColor(color: selectedColor), for: .normal)
    }
    
    @IBAction func colorClicked(_ sender: Any) {
        colorPicker.isHidden = !colorPicker.isHidden
    }
    
    @IBAction func deadlineClicked(_ sender: UIButton) {
        datePicker.isHidden = !datePicker.isHidden
        self.view.endEditing(true)
        completedLabel.isHidden = !completedLabel.isHidden
        completeIndicator.isHidden = !completeIndicator.isHidden
    }
    
    @IBAction func deadlineChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        deadline.setTitle(dateFormatter.string(from: sender.date), for: .normal)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    @objc func storeSelectedRow(){
        
    }
    
    @IBAction func completed(_ sender: UIButton) {
        if completedTF {
            sender.setBackgroundImage(uncompleteColor, for: .normal)
        } else {
            sender.setBackgroundImage(completeColor, for: .normal)
        }
        completedTF = !completedTF
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToCalendar" {
            let calendarView = segue.destination as! ViewController
            calendarView.eventList.remove(at: lastIndex)
            calendarView.dueDates.remove(at: lastIndex)
            calendarView.eventList.insert(detail, at: lastIndex + 1)
            calendarView.dueDates.insert(detail.deadline, at: lastIndex + 1)
            if completedTF {
                calendarView.completedList.append(detail)
            }
            calendarView.shouldWrite = true
        } else if segue.identifier == "unwindToList" {
            let listView = segue.destination as! ListViewController
            let calendarView = listView.tabBarController?.viewControllers?[0] as! ViewController
            listView.eventList.remove(at: lastIndex)
            calendarView.eventList.remove(at: lastIndex)
            calendarView.dueDates.remove(at: lastIndex)
            listView.eventList.insert(detail, at: lastIndex + 1)
            calendarView.eventList.insert(detail, at: lastIndex + 1)
            calendarView.dueDates.insert(detail.deadline, at: lastIndex + 1)
            if completedTF {
                listView.completedList.append(detail)
                calendarView.completedList.append(detail)
            }
            listView.shouldWrite = true
        } else {
            let multipleView = segue.destination as! MultipleDueViewController
            multipleView.eventList.remove(at: lastIndex)
            if !completedTF {
                multipleView.eventList.insert(detail, at: lastIndex + 1)
            }
        }
    }
    
    private func setUpLayout() {
        completeIndicator.layer.cornerRadius = completeIndicator.frame.width / 2
        
        dateTitle.text = formattedDate
        subject.text = detail.subject
        dueColor.setBackgroundImage(imageFromColor(color: detail.color), for: .normal)
        selectedColor = detail.color
        content.text = detail.content
        
        dateFormatter.dateFormat = "yyyy MM dd hh mm a"
        let deadlineDate = dateFormatter.date(from: detail.deadline)
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("EE MMM d hh mm")
        deadline.setTitle(dateFormatter.string(from: deadlineDate!), for: .normal)
        emergence.value = Float(detail.emergence)
        if detail.completed == "false" {
            completeIndicator.setBackgroundImage(uncompleteColor, for: .normal)
        } else {
            completeIndicator.setBackgroundImage(completeColor, for: .normal)
            completedTF = true
        }
    }
    
    private func editDone() {
        if (subject.text != nil && content.text != nil &&
            deadline.currentTitle != nil){
            
            detail.subject = subject.text!
            detail.color = selectedColor
            detail.content = content.text!
            dateFormatter.dateFormat = "yyyy MM dd hh mm a"
            let newDeadline = dateFormatter.string(from: selectedDate)
            detail.deadline = newDeadline
            detail.emergence = Int(emergence.value)
            detail.completed = String(describing: completedTF)
        }
        subject.isEnabled = false
        content.isEnabled = false
        deadline.isEnabled = false
        dueColor.isEnabled = false
        emergence.isEnabled = false
        completedLabel.isHidden = false
        completeIndicator.isHidden = false
        datePicker.isHidden = true
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
