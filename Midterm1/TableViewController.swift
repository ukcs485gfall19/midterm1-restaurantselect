//
//  TableViewController.swift
//  Midterm1
//
//  Created by Jonathan Moore on 9/24/19.
//  Copyright © 2019 Jonathan Moore. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    //Set the number of rows for the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Set rows to number of locations stored
        return LocationStorage.shared.locations.count
    }
}
