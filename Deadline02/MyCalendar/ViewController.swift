//
//  ViewController.swift
//  MyCalendar
//
//  Created by Xinyi Wang on 11/28/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CloudKit

class ViewController: UIViewController {
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearTitle: UILabel!
    @IBOutlet weak var monthTitle: UILabel!
    
    @IBOutlet weak var popoverView: UIView!
    @IBOutlet weak var dimmerView: UIView!
    
    public var eventList: Array<Due> = []
    public var dueDates: Array<String> = []
    // DATABASE SHOULD BE PRIVATE
    let database = CKContainer.default().publicCloudDatabase
    var eventsFromCloud: Array<CKRecord> = []

    private var dateDetailView: DateDetailViewController!
    private var addDueView: AddDueViewController!
    private var todaySelected: Bool = true
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // fetch data from iCloud or use local storage
        fetchData()
        
        // SetUps
        setUpCalendar()
        // set up month & year
        calendarView.visibleDates { (visibleDates) in
            let current = visibleDates.monthDates.first!.date
            
            self.dateFormatter.dateFormat = "yyyy"
            self.yearTitle.text = self.dateFormatter.string(from: current)
            self.dateFormatter.dateFormat = "MMMM"
            self.monthTitle.text = self.dateFormatter.string(from: current)
        }
        // go to today
        calendarView.scrollToDate(Date(), animateScroll: false)

        // Setup layouts
        popoverView.isHidden = true
        dimmerView.isHidden = true
        
        // build other views
        dateDetailBuilder()
        addDueBuilder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calendarView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setUpCalendar() {
        calendarView.minimumLineSpacing = 3
        calendarView.minimumInteritemSpacing = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDateDetail" {
            let dateCell = sender as! CollectionViewCell
            let detailView = segue.destination as! DateDetailViewController
            detailView.detail = dateCell.dueEvent
            detailView.formattedDate = dateCell.date
            detailView.lastView = "mainCalendar"
        } else if segue.identifier == "add" || segue.identifier == "toAddDue" {
        }
    }
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
    }
    
    @IBAction func displayPressed(_ sender: UIButton) {
        popoverView.isHidden = false
        dimmerView.isHidden = false
        
        // hide this view even not sync!
        
    }
    
    @IBAction func setted(_ sender: UIButton) {
        var errMessage = ""
        
        //        if newSource != nil && newSource != "" {
        //            let range = newSource!.startIndex..<newSource!.endIndex
        //            let correctRange = newSource!.range(of: "^(http)s?(:\\/\\/).*$", options: .regularExpression)
        //            if correctRange == range {
        //                source = newSource!
        //                fetchData()
        //            } else {
        //                errMessage = "Invalid URL"
        //            }
        //        } else {
        //            errMessage = "Please enter an URL"
        //        }
        if errMessage != "" {
            let alertController = UIAlertController(title: "ERROR", message: errMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
        
        popoverView.isHidden = true
        dimmerView.isHidden = true
    }
    
    private func dateDetailBuilder() {
        if dateDetailView == nil {
            dateDetailView = storyboard?.instantiateViewController(withIdentifier: "dateDetailViewController") as! DateDetailViewController
        }
    }
    
    private func addDueBuilder() {
        if addDueView == nil {
            addDueView = storyboard?.instantiateViewController(withIdentifier: "addDueViewController") as! AddDueViewController
        }
    }
    
    /* Fetches data from the iCloud.
     --> If succeeds, uses the cloud data writes the cloud data to a local file (creates one if no local file exists).
     --> If fails, checks if a local file exists. If the local exists, uses the local file. If not, creates an empty local file. */
    @objc func fetchData() {
        let query = CKQuery(recordType: "Due", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "deadline", ascending: true)]
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print("ERROR")
                print(error!)
                // use local data
                self.chooseLocalFile()
            } else {
                print("SUCCESS")
                // use cloud data
                guard let records = records else { return }
                if let parsedData = self.parseDataFromCloud(records) {
                    self.writeJSON(parsedData)
                }
            }
            DispatchQueue.main.async {
                self.calendarView.reloadData()
                let listView = self.tabBarController?.viewControllers?[1] as! ListViewController
                listView.eventList = self.eventList
            }
        }
    }
    
    private func parseDataFromCloud(_ records: Array<CKRecord>) -> Data? {
        // clear all previous records
        self.eventsFromCloud.removeAll()
        self.eventList.removeAll()
        self.dueDates.removeAll()
        
        var eventListJson: Array<String> = []
        for recordtemp : CKRecord in records {
            self.eventsFromCloud.append(recordtemp)
            
            let newSubject = recordtemp.value(forKeyPath: "subject") as! String
            let newColor = recordtemp.value(forKeyPath: "color") as! Array<Double>
            let newContent = recordtemp.value(forKeyPath: "content") as! String
            let newDeadline = recordtemp.value(forKeyPath: "deadline") as! String
            let newEmergence = recordtemp.value(forKeyPath: "priority") as! int_fast64_t
            
            let color = UIColor(red: CGFloat(newColor[0]), green: CGFloat(newColor[1]), blue: CGFloat(newColor[2]), alpha: 1.0)
            // add Due
            let newEvent: Due = Due.init(subject: newSubject, color: color, content: newContent, deadline: newDeadline, emergence: Int(newEmergence))
            self.eventList.append(newEvent)
            self.dueDates.append(newEvent.deadline)
            // parse Due
            if let parsed = newEvent.toJSON() {
                eventListJson.append(parsed)
            }
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: eventListJson, options: JSONSerialization.WritingOptions.prettyPrinted)
            return jsonData
        } catch {
            print(error)
            return nil
        }
    }
    
    private func chooseLocalFile() {
        if let filePath = Bundle.main.url(forResource: "Dues", withExtension: "json") {
            // use new data
            print("USE Dues.json")
            getLocalFile(filePath)
        } else {
            print("File does not exist, create it")
            var documentsDirectory: URL?
            var fileURL: URL?
            documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
            fileURL = documentsDirectory!.appendingPathComponent("Dues.json")
            NSData().write(to: fileURL!, atomically: true)
        }
    }
    
    private func getLocalFile(_ filePath: URL) {
        do {
            let file: FileHandle? = try FileHandle(forReadingFrom: filePath)
            if file != nil {
                let fileData = file!.readDataToEndOfFile()
                file!.closeFile()
                
                // TEST
                let str = NSString(data: fileData, encoding: String.Encoding.utf8.rawValue)
                print("FILE CONTENT: \(str!)")
                
                parseJSON(fileData)
                //
            }
        } catch {
            print("Error in file reading: \(error.localizedDescription)")
        }
    }
    
    private func writeJSON(_ data: Data) {
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
                print("FILE WRITE")
            } else {
                print("Unable to write JSON file!")
            }
        } catch {
            print("Error in file writing: \(error.localizedDescription)")
        }
    }
    
    private func parseJSON(_ data: Data) {
        // clear all previous records
        self.eventsFromCloud.removeAll()
        self.eventList.removeAll()
        self.dueDates.removeAll()
        
        do {
            let dueDecoded = try JSONDecoder().decode([DueDecodable].self, from: data)
            for decoded : DueDecodable in dueDecoded {
                let newSubject = decoded.subject
                let newColor = decoded.color
                let newContent = decoded.content
                let newDeadline = decoded.deadline
                let newEmergence = decoded.emergence
                
                let color = UIColor(red: newColor[0], green: newColor[1], blue: newColor[2], alpha: 1.0)
                // add Due
                let newEvent: Due = Due.init(subject: newSubject, color: color, content: newContent, deadline: newDeadline, emergence: newEmergence)
                self.eventList.append(newEvent)
                self.dueDates.append(newEvent.deadline)
            }
        } catch {
            print("ERROR in JSON parsing: \(error)")
        }
    }
}

extension ViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
//        code
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        // Can set these to whatever
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        // In the real app, do not do force unwrapping!!!
        let startDate = dateFormatter.date(from: "2017 01 01")!
        let endDate = dateFormatter.date(from: "2067 12 31")!
        let parameter = ConfigurationParameters(startDate: startDate, endDate: endDate)
        
        return parameter
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let dateCell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "cell", for:  indexPath) as! CollectionViewCell
        // set date text
        dateCell.dateLabel.text  = cellState.text
        dateFormatter.dateFormat = "MMMM dd"
        dateCell.date = dateFormatter.string(from: cellState.date)
        // set corner radius
        dateCell.layer.cornerRadius = dateCell.frame.width / 2
        dateCell.eventIndicator.layer.cornerRadius = dateCell.eventIndicator.frame.width / 2
        // set current month display
        if cellState.dateBelongsTo != .thisMonth {
            dateCell.dateLabel.textColor = UIColor(red:0.19, green:0.47, blue:0.45, alpha:1.0)
            dateCell.alpha = 0.5
        } else {
            dateCell.dateLabel.textColor = UIColor.black
        }
        // set selected
        if !checkDate(cellState, Date()) {
            if cellState.isSelected {
                dateCell.isSelected = false
            }
            dateCell.backgroundColor = UIColor(red:0.69, green:0.93, blue:0.93, alpha:1.0)
        } else {
            dateCell.backgroundColor = UIColor(red:0.56, green:0.74, blue:0.74, alpha:1.0)
            dateCell.dateLabel.textColor = UIColor.white
        }
        // set event indicator and events corresponding to a date
        dateFormatter.dateFormat = "yyyy MM dd"
        let cellStateDate = dateFormatter.string(from: cellState.date)
        if let index = dueDates.index(of: cellStateDate) {
            dateCell.eventIndicator.isHidden = false
            dateCell.eventIndicator.backgroundColor = eventList[index].color
            dateCell.dueEvent = eventList[index]
        } else {
            dateCell.eventIndicator.isHidden = true
        }
        
        return dateCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let selectedCell = cell as! CollectionViewCell? else { return }
        if !checkDate(cellState, Date()) {   // if it's not today, change the background color
            selectedCell.backgroundColor = UIColor(red:0.23, green:0.84, blue:0.78, alpha:1.0)
        }
        setSegue(selectedCell)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if !checkDate(cellState, Date()) {
            cell?.backgroundColor = UIColor(red:0.70, green:0.93, blue:0.93, alpha:1.0)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let current = visibleDates.monthDates.first!.date
        
        dateFormatter.dateFormat = "yyyy"
        yearTitle.text = dateFormatter.string(from: current)
        dateFormatter.dateFormat = "MMMM"
        monthTitle.text = dateFormatter.string(from: current)
    }
    
    private func checkDate(_ cellState: CellState, _ date: Date) -> Bool {
        dateFormatter.dateFormat = "yyyy MM dd"
        let checkDate = dateFormatter.string(from: date)
        let cellStateDate = dateFormatter.string(from: cellState.date)
        return checkDate == cellStateDate ? true : false
    }
    
    // set segue:
    //      the date has due ---> toDateDetail
    //      the date has no due ---> toAddDue
    private func setSegue(_ selectedCell: CollectionViewCell) {
        if selectedCell.dueEvent.subject != "" {
            let segueTemp = UIStoryboardSegue.init(identifier: "toDateDetail", source: self, destination: dateDetailView)
            selectedCell.segueTo = segueTemp
            performSegue(withIdentifier: "toDateDetail", sender: selectedCell)
        } else {
            let segueTemp = UIStoryboardSegue.init(identifier: "toAddDue", source: self, destination: addDueView)
            selectedCell.segueTo = segueTemp
            performSegue(withIdentifier: "toAddDue", sender: selectedCell)
        }
    }
    
}
