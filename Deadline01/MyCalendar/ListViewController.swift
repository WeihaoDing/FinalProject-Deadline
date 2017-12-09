//
//  ListViewController.swift
//  MyCalendar
//
//  Created by Xinyi Wang on 12/5/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    private var eventList: Array<Due> = []

    private var items: Array<ListTableViewCell> = []
    private var dateDetailViewController: DateDetailViewController!

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ListTableViewCell
        if let celltry = self.tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = celltry as! ListTableViewCell
        } else {
            cell = ListTableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        }
        
        // IMAGE? A DOT!!!
//        cell.imageView?.image = self.images[indexPath.row - 3 * (indexPath.row / 3)]
        
        cell.textLabel?.text = self.eventList[indexPath.row].subject
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.text = self.eventList[indexPath.row].content
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = self.eventList[indexPath.row].color
        cell.backgroundColor!.withAlphaComponent(0.5)
        
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
    @IBOutlet weak var displaySetting: UIButton!
    
    @IBOutlet weak var popoverView: UIView!
    @IBOutlet weak var dimmerView: UIView!

    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(ListTableViewCell.self, forCellReuseIdentifier: "cell")
        
        popoverView.isHidden = true
        popoverView.layer.cornerRadius = 10
        dimmerView.isHidden = true

        
//        self.fetchData()
        
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
    }

    @objc private func refreshData(sender: UIRefreshControl) {
//        fetchData()
        refreshControl.endRefreshing()
    }

    @IBAction func displayPressed(_ sender: UIButton) {
        popoverView.isHidden = false
        dimmerView.isHidden = false
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellToDetail" {
            let datedetailView = segue.destination as! DateDetailViewController
            let cell = sender as! UITableViewCell
            
            datedetailView.lastView = "listView"
            
//            questionView.questionIndex = 0
//            let titleIndex = subjects.index(of: cell.textLabel!.text!)
//            questionView.questionList = questionList[titleIndex!].text
//            questionView.correctIndex = questionList[titleIndex!].answer
//            questionView.choiceList = questionList[titleIndex!].answers
        }
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

    /* Fetches data from the source URL.
     --> If succeeds, uses the JSON data writes the JSON to a local file (creates one if no local file exists).
     --> If fails, checks if a local file exists. If the local exists, uses the local file. If not, uses the original read-only data in the application bundle. */
//    private func fetchData() {
//        guard let url = URL(string: source) else { return }
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            let httpResponse = response as? HTTPURLResponse
//            if httpResponse != nil && httpResponse?.statusCode == 200 {
//                print("statusCode: \(httpResponse!.statusCode)")
//
//                guard let data = data else { return }
//                if self.parseJSON(data) {
//                    self.writeJSON(data)
//                } else {
//                    let alertController = UIAlertController(title: "ERROR", message: "Invalid Source URL!", preferredStyle: .alert)
//                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                    alertController.addAction(okAction)
//                    self.present(alertController, animated: true)
//                    self.chooseLocalFile()
//                }
//            } else {
//                print("NETWORK ERROR")
//                // use local file
//                self.chooseLocalFile()
//            }
//            DispatchQueue.main.async {
//                print("FINISH")
//                self.tableView.reloadData()
//            }
//            }.resume()
//    }
//
//    private func chooseLocalFile() {
//        if let filePath = Bundle.main.url(forResource: "NewData", withExtension: "json") {
//            // use new data
//            print("NewData")
//            getLocalFile(filePath)
//        } else if let filePath = Bundle.main.url(forResource: "Data", withExtension: "txt") {
//            // use original read-only data
//            print("OldData")
//            getLocalFile(filePath)
//        } else {
//            print("INVALID FILEPATH")
//        }
//    }
//
//    private func getLocalFile(_ filePath: URL) {
//        do {
//            let file: FileHandle? = try FileHandle(forReadingFrom: filePath)
//            if file != nil {
//                let fileData = file!.readDataToEndOfFile()
//                file!.closeFile()
//                //                let str = NSString(data: fileData, encoding: String.Encoding.utf8.rawValue)
//                //                print("FILE CONTENT: \(str!)")
//                let _ = parseJSON(fileData)
//            }
//        } catch {
//            print("Error in file reading: \(error.localizedDescription)")
//        }
//    }
//
//    private func parseJSON(_ data: Data) -> Bool {
//        var result = true
//        do {
//            let quiz = try JSONDecoder().decode([Quiz].self, from: data)
//            self.subjects.removeAll()
//            self.descriptions.removeAll()
//            self.questionList.removeAll()
//
//            for element in quiz {
//                self.subjects.append(element.title)
//                self.descriptions.append(element.desc)
//                var textTemp: Array<String> = []
//                var answerTemp: Array<Int> = []
//                var choicesTemp: Array<Array<String>> = []
//                for question in element.questions {
//                    textTemp.append(question.text)
//                    answerTemp.append(Int.init(question.answer)! - 1)
//                    var choiceTemp: Array<String> = []
//                    for i in 0...question.answers.count - 1 {
//                        choiceTemp.append("\(self.choicesTitle[i]) \(question.answers[i])")
//                    }
//                    choicesTemp.append(choiceTemp)
//                }
//                self.questionList.append(QuestionsList.init(text: textTemp, answer: answerTemp, answers: choicesTemp))
//            }
//        }  catch let jsonError {
//            print("Error in JSON Serialization:", jsonError)
//            result = false
//        }
//        return result
//    }
//
//    private func writeJSON(_ data: Data) {
//        var documentsDirectory: URL?
//        var fileURL: URL?
//
//        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
//        fileURL = documentsDirectory!.appendingPathComponent("NewData.json")
//        do {
//            let checkFile: FileHandle? = try FileHandle(forWritingTo: fileURL!)
//            if checkFile == nil {
//                print("File does not exist, create it")
//                NSData().write(to: fileURL!, atomically: true)
//            } else {
//                print("File exists")
//            }
//        } catch {
//            print("Error in file creating: \(error.localizedDescription)")
//        }
//        do {
//            let newFile: FileHandle? = try FileHandle(forWritingTo: fileURL!)
//            if newFile != nil {
//                newFile!.write(data)
//                print("FILE WRITE")
//            } else {
//                print("Unable to write JSON file!")
//            }
//        } catch {
//            print("Error in file writing: \(error.localizedDescription)")
//        }
//    }
    
    


}
