//
//  AddDueViewController.swift
//  MyCalendar
//
//  Created by Xinyi Wang on 11/29/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit

class AddDueViewController: UIViewController, UIPopoverPresentationControllerDelegate{

    @IBOutlet weak var subText: UITextField!
    @IBOutlet weak var conText: UITextField!

    @IBOutlet weak var dateButton: UIButton!
    
    var selectedDate : Date?
    
    @IBAction func dateButtonClicked(_ sender: UIButton) {
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        print("DATE :: \(datePicker.date)")
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
        let subData : String = subText.text!
        let conData : String = conText.text!
        
        
        let due = Due(subject: subData, color: UIColor.black, content: conData, deadline: (Date().description), emergence: 10)
        
        let alert = UIAlertController(title: "confirmation", message: "You have added a Due successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            action in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nvc = storyBoard.instantiateViewController(withIdentifier: "mainCalendar")
            self.present(nvc, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDatePicker" {
            let popoverViewController = segue.destination as! DatePickerViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self as UIPopoverPresentationControllerDelegate
            selectedDate = popoverViewController.date
            dateButton.setTitle(selectedDate?.description, for: .normal)
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        

       
        // Do any additional setup after loading the view.
    }
    
    @objc func storeSelectedRow(){

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
