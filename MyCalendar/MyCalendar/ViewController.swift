//
//  ViewController.swift
//  MyCalendar
//
//  Created by Xinyi Wang on 11/28/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearTitle: UILabel!
    @IBOutlet weak var monthTitle: UILabel!
    
    public var eventList: Array<Due> = []
    public var dueDates: Array<String> = []
    
    private var dateDetailView: DateDetailViewController!
    private var addDueView: AddDueViewController!
    private var todaySelected: Bool = true
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        // Fetch Events
        fetchEvents()
        
        // build other views
        dateDetailBuilder()
        addDueBuilder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setUpCalendar() {
        calendarView.minimumLineSpacing = 3
        calendarView.minimumInteritemSpacing = 0
    }
    
    private func fetchEvents() {
        let eventTemp: Due = Due.init(subject: "INFO", color: UIColor.yellow, content: "Final Project", deadline: "2017 11 30", emergence: 1)
        
        eventList.append(eventTemp)
        dueDates.append(eventTemp.deadline)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDateDetail" {
            let dateCell = sender as! CollectionViewCell
            let detailView = segue.destination as! DateDetailViewController
            detailView.detail = dateCell.dueEvent
            detailView.formattedDate = dateCell.date
        } else if segue.identifier == "add" || segue.identifier == "toAddDue" {
        }
    }
    
    @IBAction func unwindToViewController(unwindSegue: UIStoryboardSegue) {
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
