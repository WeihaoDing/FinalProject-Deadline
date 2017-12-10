//
//  TabBarShareController.swift
//  MyCalendar
//
//  Created by Xinyi Wang on 12/10/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit
import CloudKit

class TabBarShareController: UITabBarController {
    
    private var eventList: Array<Due> = []
    
    // DATABASE SHOULD BE PRIVATE
    let database = CKContainer.default().publicCloudDatabase
    var eventsFromCloud: Array<CKRecord> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        DispatchQueue.global().sync {
//            self.fetchData()
//            let calendarView = self.viewControllers?.first as! ViewController
//            calendarView.eventList = self.eventList
//            //        let listView = self.tabBarController?.viewControllers![1] as! ListViewController
//            //        listView.eventList = self.eventList
//
//            // dispatch?
////            DispatchQueue.main.sync {
////                print("FINISH")
//////                self.reloadInputViews()
////            }
//        }
        


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            let color = UIColor(red: CGFloat(newColor[0]), green: CGFloat(newColor[1]), blue: CGFloat(newColor[2]), alpha: 1.0)
            // add Due
            let newEvent: Due = Due.init(subject: newSubject, color: color, content: newContent, deadline: newDeadline, emergence: Int(newEmergence))
            self.eventList.append(newEvent)
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
            }
        } catch {
            print("ERROR in JSON parsing: \(error)")
        }
    }
}
