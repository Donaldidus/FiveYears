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

    var memories: [String]?
    
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
            for child in snapshot.children {
                if let childSnap = child as? FIRDataSnapshot {
                    self.memories?.append(childSnap.key)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardIdentifier.memorycell, for: indexPath)
        
        if let memo = memories {
            // query the firebase database for the title of the given memory
            DataService.ds.REF_MEMORIES.child(memo[indexPath.row]).child(DataBaseKeys.title).observe(.value, with: { (snapshot) in
                // set the text of the cell to the title received from database
                cell.textLabel?.text = snapshot.value as? String ?? "No title available."
                // read timestamp from memories (default is 18. May 2012) and convert it to a readable date
                let timestamp = Double(memo[indexPath.row]) ?? 1337299200 // = 18th May 2012
                cell.detailTextLabel?.text = self.dateFor(timestamp: timestamp)
            })
        }
        return cell
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
