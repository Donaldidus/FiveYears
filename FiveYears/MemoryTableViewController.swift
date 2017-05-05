//
//  MemoryTableViewController.swift
//  FiveYears
//
//  Created by Jan B on 04.05.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import UIKit
import FirebaseDatabase


class MemoryTableViewController: UITableViewController {

    /// Array containing all memory keys (timestamp from 1970 on) for the database.
    var memories: [String]?
    
    /// Set the dateFormatter to set the date in the tableView how you'd like.
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMemories()
        
        // This will cause the tableView to not display any empty cells/rows.
        tableView.tableFooterView = UIView(frame: .zero)
        
        // If the MemoryTableVC is embedded in a Navigation Controller set the Textcolor to white
        // (I didn't find any way to set this in the Storyboard :O)
        if let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
        }
        
    }
    
    @IBAction func reloadContent(_ sender: UIBarButtonItem) {
        fetchMemories()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // size of the table view is the number of current memories
        if let mem = memories {
            return mem.count
        }
        return 0
    }
    
    /// Will convert a timestamp for the time interval since 1970 to a humanly readable date with the MemoryTableViewControllers
    /// dateFormatter. For any date formatting edit the dateFormatter property.
    ///
    /// - Parameter timestamp: The timestamp (from 1970 on) to convert.
    /// - Returns: Converted String according to the dateFormatter.
    private func dateFor(timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        return dateFormatter.string(from: date)
    }
    
    /// Fetches all available memory keys from the database and stores them in the memories property.
    private func fetchMemories() {
        // Empty all preloaded memories
        memories = [String]()
        
        // get the current date and remove decimal (firebase won't accept floating point)
        let today = String(Int(Date().timeIntervalSince1970))
        
        // run the firebase query for all memories in the past (ignore future memories)
        DataService.ds.REF_MEMORIES.queryEnding(atValue: nil, childKey: today).observe(.value, with: { (snapshot) in
            // The first child is the latest database entry.
            for child in snapshot.children.reversed() {
                if let childSnap = child as? FIRDataSnapshot {
                    self.memories?.append(childSnap.key)
                }
            }
            self.tableView.reloadData()
        })
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // In case this is an unwind to memory segue pass it the selected memory.
        if segue.identifier == StoryboardIdentifier.UnwindMemorySegue {
            if let destinationVC = segue.destination as? MemoryViewController {
                if let selectedCell = sender as? UITableViewCell {
                    let selectedPath = tableView.indexPath(for: selectedCell)!
                    if let memos = memories {
                        destinationVC.currentMemory = memos[selectedPath.row]
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifier.memorycell, for: indexPath)
        
        if let memoryCell = cell as? MemoryTableViewCell {
            if let memo = memories {
                // query the firebase database for the title of the given memory
                DataService.ds.REF_MEMORIES.child(memo[indexPath.row]).child(DataBaseKeys.title).observe(.value, with: { (snapshot) in
                    // set the text of the cell to the title received from database
                    memoryCell.titleLabel.text = snapshot.value as? String ?? "No title available."
                    // read timestamp from memories (default is 18. May 2012) and convert it to a readable date
                    let timestamp = Double(memo[indexPath.row]) ?? 1337299200 // = 18th May 2012
                    memoryCell.dateLabel.text = self.dateFor(timestamp: timestamp)
                })
            }
            return memoryCell
        }
        return cell
    }

}
