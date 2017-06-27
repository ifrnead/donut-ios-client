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
        
        static let serverPrefix: String = "http://localhost:3000"
        static let listUsersService: String = "\(serverPrefix)/api/users"
        
        static let defaultsTokenKey: String = "tokenKey"
        
        static let tableViewUserCellIdentifier: String = "User Cell"
        
    }
    
    // MARK: - Outlets
    
    
    
    // MARK: - Actions
    
    @IBAction func reload(_ sender: UIRefreshControl) {
        
        requestUsersIfAlreadyAuthenticated()
        
    }
    
    // MARK: - Model
    

    
    // MARK: - Network
    
    private func requestUsersAsync(with token: String) {
        
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

                    let jsonResponse = JSON(value)
                    
                    self?.container?.performBackgroundTask { context in
                        for (index, jsonObject):(String, JSON) in jsonResponse {
                            print("Index: \(index)")
                            print("Json: \(jsonObject)")
                            _ = try? User.findOrCreateUser(with: jsonObject, in: context)
                        }
                        try? context.save()
                        
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                            self?.refreshControl?.endRefreshing()
                        }
                    }
                    
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
    
    private func requestUsersIfAlreadyAuthenticated() {
        if isAuthenticated {
            requestUsersAsync(with: token!)
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestUsersIfAlreadyAuthenticated()
        
        updateFetchedResultsController()
        
    }
    
    // MARK: - CoreData
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    // MARK: - UITableViewDataSource
    
    var fetchedResultsController: NSFetchedResultsController<User>?
    
    private func updateFetchedResultsController() {
        
        if let context = container?.viewContext, isAuthenticated {
            
            let request: NSFetchRequest<User> = User.fetchRequest()
            
            // request.predicate ...
            
            request.sortDescriptors = [
                NSSortDescriptor(
                    key: "name",
                    ascending: true,
                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )
            ]
            
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
