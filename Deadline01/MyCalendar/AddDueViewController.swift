//
//  AddDueViewController.swift
//  MyCalendar
//
//  Created by Xinyi Wang on 11/29/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit

class AddDueViewController: UIViewController, UIPopoverPresentationControllerDelegate{

    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var subText: UITextField!
    @IBOutlet weak var conText: UITextField!
    @IBOutlet weak var colorPickerStack: UIStackView!
    @IBOutlet weak var dateButton: UIButton!
    
    private var selectedColor: UIColor = UIColor(red:0.99, green:0.96, blue:0.16, alpha:1.0)
    
    var selectedDate = Date()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("EE MMM d hh mm")
        dateButton.setTitle(dateFormatter.string(from: selectedDate), for: .normal)
        colorPickerStack.isHidden = true
        datePicker.isHidden = true
        
    }
    
    @IBAction func dateButtonClicked(_ sender: UIButton) {
        datePicker.isHidden = !datePicker.isHidden
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
    
    
    /*
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // edited
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let date = dateFormatter.date(from:myDate)!
    dateFormatter.dateFormat = "dd/MM/yyyy"
    let dateString = dateFormatter.string(from:date)
    */
    @IBAction func addDue(_ sender: UIButton) {
//        let subData : String = subText.text!
//        let conData : String = conText.text!
//
//
//        let due = Due(subject: subData, color: UIColor.black, content: conData, deadline: (Date().description), emergence: 10)
//
//        let alert = UIAlertController(title: "confirmation", message: "You have added a Due successfully!", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
//            action in
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let nvc = storyBoard.instantiateViewController(withIdentifier: "mainCalendar")
//            self.present(nvc, animated: true, completion: nil)
//        }))
//        self.present(alert, animated: true, completion: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showColorPicker" {
            let popoverViewController = segue.destination
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self as UIPopoverPresentationControllerDelegate


        }
    }
    
    @objc func storeSelectedRow(){

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
