//
//  RoomsTableViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 27/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData


class RoomsTableViewController: FetchedResultsTableViewController {

    // MARK: - Constants
    
    private struct Constants {
        
        static let tableViewRoomCellIdentifier: String = "Room Cell"
        
        static let segueToMessagesTableViewController: String = "Segue To MessagesTableViewController"
        
    }
    
    // MARK: - Outlets
    
    

    // MARK: - Actions

    @IBAction func reload(_ sender: UIRefreshControl) {
        
        requestRoomsIfAlreadyAuthenticated()
        
    }

    
    // MARK: - Model
    
    
    
    // MARK: - Network
    
    private func requestRoomsAsync(with token: String) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)",
            "Accept": "application/json"
        ]
        
        Alamofire.request(DonutServer.Constants.listRoomsService,
                          method: .get,
                          headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { [weak self] response in
                
                switch response.result {
                    
                case .success(let data):
                    
                    debugPrint("SUCCESS: ", data)
                    
                    let json = JSON(data)
                    
                    self?.container?.performBackgroundTask { context in
                        for (_, jsonObject):(String, JSON) in json {
                            _ = try? Room.findOrCreateRoom(with: jsonObject, in: context)
                        }
                        try? context.save()
                        
                        DispatchQueue.main.async {
                            self?.refreshControl?.endRefreshing()
                        }
                    }

                case .failure(let error):
                    
                    debugPrint("ERROR: ", error)
                    
                }
                
        }
        
    }
    
    // MARK: - Private Implementation
    
    private func requestRoomsIfAlreadyAuthenticated() {
        if DonutServer.isAuthenticated {
            requestRoomsAsync(with: DonutServer.token!)
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestRoomsIfAlreadyAuthenticated()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateFetchedResultsController()
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Constants.segueToMessagesTableViewController:
                // prepare MessagesTableViewController
                if let messagesTableViewController = segue.destination as? MessagesTableViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        if let room = fetchedResultsController?.object(at: indexPath) {
                            messagesTableViewController.room = room
                        }
                    }
                }
            default: break
                // do nothing
            }
        }
    }
    
    // MARK: - CoreData
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var fetchedResultsController: NSFetchedResultsController<Room>?
    
    private func updateFetchedResultsController() {
        
        if let context = container?.viewContext {
            
            context.automaticallyMergesChangesFromParent = true
            
            let request: NSFetchRequest<Room> = Room.fetchRequest()
            
            // request.predicate ...
            
            request.sortDescriptors = [
                NSSortDescriptor(
                    key: "curricular_component",
                    ascending: true,
                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )
            ]
            
            fetchedResultsController = NSFetchedResultsController<Room>(
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewRoomCellIdentifier, for: indexPath)
        if let room = fetchedResultsController?.object(at: indexPath) {
            if let name = room.curricular_component {
                cell.textLabel?.text = name
            }
        }
        return cell
    }

}


extension RoomsTableViewController {
    
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

