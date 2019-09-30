//
//  TableViewController.swift
//  Midterm1
//
//  Created by Jonathan Moore on 9/24/19.
//  Copyright © 2019 Jonathan Moore. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register a method to be called when notification arrives
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(newLocationAdded(_:)),
        name: .newLocationSaved,
        object: nil)
    }
    
    // receive notification as parameter
    @objc func newLocationAdded(_ notification: Notification) {
        
        // reload list
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let location = LocationStorage.shared.locations[indexPath.row]
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.text = location.description
        cell.detailTextLabel?.text = location.dateString
        return cell
    }
}
