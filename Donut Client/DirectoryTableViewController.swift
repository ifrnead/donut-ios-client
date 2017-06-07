//
//  DirectoryTableViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 07/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit

class DirectoryTableViewController: UITableViewController {
    
    // MARK: - Model
    
    public var Contacts: [[String: String]] = [["": ""]]
    
    // MARK: - UITableViewControllerLifeCycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        performSegue(withIdentifier: "Show Login", sender: nil)
        
    }
    
    // MARK: - UITableViewController
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Directory Cell", for: indexPath)
        // configure cell
        return cell
    }
    
}
