//
//  UsersTableViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 22/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData


class UsersTableViewController: FetchedResultsTableViewController {
    
    // MARK: - Constants
    
    private struct Constants {
        
        static let serverPrefix: String = "http://10.123.1.128:3000"
        static let listUsersService: String = "\(serverPrefix)/api/users"
        static let suapPrefix: String = "http://suap.ifrn.edu.br"
        
        static let defaultsTokenKey: String = "tokenKey"
        
        static let tableViewUserCellIdentifier: String = "User Cell"
        
    }
    
    // MARK: - Outlets
    
    
    
    // MARK: - Actions
    
    
    
    // MARK: - Model
    
    private var users: [User] = []
    
    // MARK: - Network
    
    private func requestUsers(with token: String) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)",
            "Accept": "application/json"
        ]
        
        Alamofire.request(Constants.listUsersService,
                          method: .get,
                          headers: headers)
            .validate(contentType: ["application/json"])
            .responseJSON { [weak self] response in
                
                switch response.result {
                    
                case .success(let value):
                    
                    debugPrint("Response: \(value)")
                    
                    let jsonResponse = JSON(value)
                    
                    print(jsonResponse)
                    
                case .failure(let error):
                    
                    debugPrint("Error: \(error)")
                    
                    // servidor deu erro por algum motivo
                    
                }
                
        }
        
    }
    
    // MARK: - Private Implementation
    
    private var token: String? {
        return UserDefaults.standard.string(forKey: Constants.defaultsTokenKey)
    }
    
    private var isAuthenticated: Bool {
        return (token != nil) ? true : false
    }
    
    // MARK: - CoreData
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isAuthenticated {
            requestUsers(with: token!)
        }
        
        updateUI()
        
    }
    
    
    // MARK: - UITableViewDataSource
    
    var fetchedResultsController: NSFetchedResultsController<User>?
    
    private func updateUI() {
        if let context = container?.viewContext, isAuthenticated {
            let request: NSFetchRequest<User> = User.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(
                key: "name",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]
            
            fetchedResultsController = NSFetchedResultsController<User>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewUserCellIdentifier, for: indexPath)
        if let user = fetchedResultsController?.object(at: indexPath) {
            if let name = user.name {
                cell.textLabel?.text = name
            }
        }
        return cell
    }

}


extension UsersTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
}

