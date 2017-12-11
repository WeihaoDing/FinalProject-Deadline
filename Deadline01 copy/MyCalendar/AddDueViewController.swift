//
//  AddDueViewController.swift
//  MyCalendar
//
//  Created by Xinyi Wang on 11/29/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit
import CloudKit

class AddDueViewController: UIViewController, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var subText: UITextField!
    @IBOutlet weak var conText: UITextField!
    @IBOutlet weak var colorPickerStack: UIStackView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var emerg: UISlider!
    
    public var eventList: Array<Due> = []
    private var selectedColor: UIColor = UIColor(red:0.99, green:0.96, blue:0.16, alpha:1.0)
    private var selectedDate = Date()
    
    // DATABASE SHOULD BE PRIVATE
    let database = CKContainer.default().publicCloudDatabase
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.conText.delegate = self
        
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("EE MMM d hh mm")
        dateButton.setTitle(dateFormatter.string(from: selectedDate), for: .normal)
        colorPickerStack.isHidden = true
        datePicker.isHidden = true
        
    }
    
    // Dismisses the keyboard if needed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func dateButtonClicked(_ sender: UIButton) {
        datePicker.isHidden = !datePicker.isHidden
        self.view.endEditing(true)
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        dateButton.setTitle(dateFormatter.string(from: sender.date), for: .normal)
        
    }
    
    @IBAction func colorButtonClicked(_ sender: UIButton) {
        colorPickerStack.isHidden = !colorPickerStack.isHidden
    }
    
    @IBAction func colorPicked(_ sender: UIButton) {
        colorPickerStack.isHidden = true
        selectedColor = sender.backgroundColor!
        colorButton.setBackgroundImage(imageFromColor(color: selectedColor), for: .normal)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    // Save the new Due to iCloud, and the local file
    @IBAction func addDue(_ sender: UIButton) {
        // check if the inputs are VALID!
        // check subject
        //
        //
        let subjectData = subText.text!
        let contentData = conText.text!
        dateFormatter.dateFormat = "yyyy MM dd hh mm a"
        let deadline = dateFormatter.string(from: selectedDate)
        let emergence = Int(emerg.value)
        // save to local
        let due = Due(subject: subjectData, color: selectedColor, content: contentData, deadline: deadline, emergence: emergence)
        eventList.append(due)
        var dueJSONArr: Array<String> = []
        for event : Due in eventList {
            dueJSONArr.append(event.toJSON()!)
        }
        if let converted = convertToJSON(dueJSONArr) {
            writeToLocalFile(converted)
        } else {
            print("Error: Cannot convert to JSON")
        }
        // save to cloud
        let colorArrTemp = selectedColor.components
        let colorArr = [colorArrTemp.red, colorArrTemp.green, colorArrTemp.blue]

        let newDue = CKRecord(recordType: "Due")
        newDue.setValue(subjectData, forKey: "subject")
        newDue.setValue(colorArr, forKey: "color")
        newDue.setValue(contentData, forKey: "content")
        newDue.setValue(deadline, forKey: "deadline")
        newDue.setValue(emergence, forKey: "priority")

        database.save(newDue) { (record, error) in
            guard record != nil else { return }
            print("SAVED TO CLOUD")
        }
        
        // pass the new eventList to calendar, list, and stats
        self.performSegue(withIdentifier: "unwindToCalendar", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToCalendar" {
            let calendarView = segue.destination as! ViewController
            calendarView.eventList = eventList
        }
    }
    
    @objc func storeSelectedRow(){

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func convertToJSON(_ due: Array<String>) -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: due, options: JSONSerialization.WritingOptions.prettyPrinted)
            return jsonData
        } catch {
            print(error)
            return nil
        }
    }
    
    private func writeToLocalFile(_ data: Data) {
        var documentsDirectory: URL?
        var fileURL: URL?
        
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        fileURL = documentsDirectory!.appendingPathComponent("Dues.json")
        if Bundle.main.url(forResource: "Dues", withExtension: "json") != nil {
            print("File exists")
        } else {
            print("File does not exist, create it")
            NSData().write(to: fileURL!, atomically: true)
        }
        do {
            let newFile: FileHandle? = try FileHandle(forWritingTo: fileURL!)
            if newFile != nil {
                newFile!.write(data)
                print("NEW DUE ADDED")
            } else {
                print("Unable to write JSON file!")
            }
        } catch {
            print("Error in file writing: \(error.localizedDescription)")
        }
        // DEBUG
        do {
            let file: FileHandle? = try FileHandle(forReadingFrom: fileURL!)
            if file != nil {
                let fileData = file!.readDataToEndOfFile()
                file!.closeFile()
                let str = NSString(data: fileData, encoding: String.Encoding.utf8.rawValue)
                print("FILE CONTENT: \(str!)")
            }
        } catch {
            print("Error in file reading: \(error.localizedDescription)")
        }
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
