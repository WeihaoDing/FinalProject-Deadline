//
//  ListViewController.swift
//  MyCalendar
//
//  Created by Xinyi Wang on 12/5/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit
import CloudKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    public var eventList: Array<Due> = []
    public var completedList: Array<Due> = []
    public var shouldWrite: Bool = false
    // DATABASE SHOULD BE PRIVATE
    let database = CKContainer.default().publicCloudDatabase
    var eventsFromCloud: Array<CKRecord> = []
    
    private var items: Array<ListTableViewCell> = []
    private var dateDetailViewController: DateDetailViewController!
    
    let dateFormatter = DateFormatter()
    
    // Tableview
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            eventList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ListTableViewCell
        if let celltry = self.tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = celltry as! ListTableViewCell
        } else {
            cell = ListTableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        }
        cell.dueEvent = eventList[indexPath.row]
        dateFormatter.dateFormat = "yyyy MM dd hh mm a"
        let date = dateFormatter.date(from: cell.dueEvent.deadline)!
        dateFormatter.dateFormat = "MMMM dd"
        cell.date = dateFormatter.string(from: date)
        
        // IMAGE? A DOT!!!
        //        cell.imageView?.image = self.images[indexPath.row - 3 * (indexPath.row / 3)]
        
        cell.textLabel?.text = self.eventList[indexPath.row].subject
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.text = ("\(self.eventList[indexPath.row].content), Due: \(self.eventList[indexPath.row].deadline)")
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        if eventList[indexPath.row].completed == "false" {
            cell.backgroundColor = self.eventList[indexPath.row].color.withAlphaComponent(0.2)
        } else {
            cell.backgroundColor = UIColor(red:0.91, green:0.94, blue:0.96, alpha:1.0)
        }
        items.append(cell)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        datedetailBuilder()
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "cellToDetail", sender: cell)
    }
    
    
    // Storyboard ViewController
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var popoverViewSub: UIView!
    @IBOutlet weak var dimmerViewSub: UIView!
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(ListTableViewCell.self, forCellReuseIdentifier: "cell")
        
        popoverViewSub.isHidden = true
        popoverViewSub.layer.cornerRadius = 10
        dimmerViewSub.isHidden = true
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(ListViewController.refreshData(sender:)), for: .valueChanged)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        if shouldWrite {
            if let parsedEventList = parseEventList() {
                writeJSON(parsedEventList)
            }
        }
    }
    
    @IBAction func editButtonClicked(_ sender: UINavigationItem) {
        if(self.tableView.isEditing == true) {
            self.tableView.isEditing = false
            sender.title = "Edit"
        } else {
            self.tableView.isEditing = true
            sender.title = "Done"
        }
    }
    
    @objc private func refreshData(sender: UIRefreshControl) {
        fetchData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func settingsPressed(_ sender: UIBarButtonItem) {
        popoverViewSub.isHidden = false
        dimmerViewSub.isHidden = false
    }

    @IBAction func applied(_ sender: UIButton) {
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
        
        popoverViewSub.isHidden = true
        dimmerViewSub.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellToDetail" {
            let datedetailView = segue.destination as! DateDetailViewController
            let dateCell = sender as! ListTableViewCell
            datedetailView.detail = dateCell.dueEvent
            datedetailView.formattedDate = dateCell.date
            datedetailView.lastView = "listView"
            datedetailView.lastIndex = eventList.index(where: { $0.toJSON() == dateCell.dueEvent.toJSON() })!
        }
    }
    
    @IBAction func unwindToListViewController(segue: UIStoryboardSegue) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func datedetailBuilder() {
        if dateDetailViewController == nil {
            dateDetailViewController = storyboard?.instantiateViewController(withIdentifier: "dateDetailViewController") as! DateDetailViewController
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
                self.tableView.reloadData()
                let calendarView = self.tabBarController?.viewControllers?[0] as! ViewController
                calendarView.eventList = self.eventList
                calendarView.dueDates.removeAll()
                for duedate : Due in self.eventList {
                    calendarView.dueDates.append(duedate.deadline)
                }
                let statsView = self.tabBarController?.viewControllers?[2] as! StatsViewController
                statsView.eventList = self.eventList
                statsView.shouldCalc = true
            }
        }
    }
    
    private func parseDataFromCloud(_ records: Array<CKRecord>) -> Data? {
        // clear all previous records
        self.eventsFromCloud.removeAll()
        self.eventList.removeAll()
        
        var eventListJson: Array<String> = []
        for recordtemp : CKRecord in records {
            self.eventsFromCloud.append(recordtemp)
            
            let newSubject = recordtemp.value(forKeyPath: "subject") as! String
            let newColor = recordtemp.value(forKeyPath: "color") as! Array<Double>
            let newContent = recordtemp.value(forKeyPath: "content") as! String
            let newDeadline = recordtemp.value(forKeyPath: "deadline") as! String
            let newEmergence = recordtemp.value(forKeyPath: "priority") as! int_fast64_t
            let newCompleted = recordtemp.value(forKeyPath: "completed") as! String
            let newRecordName = recordtemp.recordID.recordName 
            
            let color = UIColor(red: CGFloat(newColor[0]), green: CGFloat(newColor[1]), blue: CGFloat(newColor[2]), alpha: 1.0)
            // add Due
            let newEvent: Due = Due.init(subject: newSubject, color: color, content: newContent, deadline: newDeadline, emergence: Int(newEmergence), completed: newCompleted, recordName: newRecordName)
            self.eventList.append(newEvent)
            if newCompleted == "true" {
                self.completedList.append(newEvent)
            }
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
        do {
            let checkFile: FileHandle? = try FileHandle(forWritingTo: fileURL!)
            if checkFile == nil {
                print("File does not exist, create it")
                NSData().write(to: fileURL!, atomically: true)
            } else {
                print("File exists")
            }
        } catch {
            print("Error in file creating: \(error.localizedDescription)")
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
        
        do {
            let dueDecoded = try JSONDecoder().decode([DueDecodable].self, from: data)
            for decoded : DueDecodable in dueDecoded {
                let newSubject = decoded.subject
                let newColor = decoded.color
                let newContent = decoded.content
                let newDeadline = decoded.deadline
                let newEmergence = decoded.emergence
                let newCompleted = decoded.completed
                let newRecordName = decoded.recordName

                let color = UIColor(red: newColor[0], green: newColor[1], blue: newColor[2], alpha: 1.0)
                // add Due
                let newEvent: Due = Due.init(subject: newSubject, color: color, content: newContent, deadline: newDeadline, emergence: newEmergence, completed: newCompleted, recordName: newRecordName)
                self.eventList.append(newEvent)
                if newCompleted == "true" {
                    self.completedList.append(newEvent)
                }
            }
        } catch {
            print("ERROR in JSON parsing: \(error)")
        }
    }
    
    private func parseEventList() -> Data? {
        var eventListJson: Array<String> = []
        for event : Due in eventList {
            if let parsed = event.toJSON() {
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
    
}

