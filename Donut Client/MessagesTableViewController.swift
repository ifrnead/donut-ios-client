//
//  MessagesTableViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 29/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import ActionCableClient


class MessagesTableViewController: UITableViewController {

    // MARK: - Constants
    
    private struct Constants {
        
        static let tableViewMessageCellIdentifier: String = "Message Cell"
        
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var messageTextField: UITextField!
    
    // MARK: - Actions
    
    @IBAction func sendMessage(_ sender: UIBarButtonItem) {
        
        send(text: "teste")
        
    }
    
    // MARK: - Model
    
    var room: Room? {
        didSet {
            debugPrint("VIEWCONTROLLER ROOM DIDSET: ", room ?? "Not Setted.")
        }
    }
    
    private var messages: [Message] = []
    
    // MARK: - Network
    
    private var client: ActionCableClient!
    
    private var channel: Channel?
    
    // MARK: - Private Implementation
    
    func send(text: String) {
        guard let channel = channel else { return }
        // send message
        if let error = channel.action("send_message", with: ["content": text, "room_id": 1]) {
            print("Error: ", error)
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = ActionCableClient(url: URL(string: "ws://localhost:3000/cable")!)
        client.headers = [
            "token": DonutServer.token!
        ]
        client.connect()
        
        client.onConnected = { [weak self] in
            print("Connected!")
            
            self?.channel = self?.client.create("ChatRoomsChannel",
                                                identifier: ["room_id": 1],
                                                autoSubscribe: true,
                                                bufferActions: true)
            
            if let channel = self?.channel {
                channel.onReceive = { (receivedJson : Any?, error : Error?) in
                    if let error = error {
                        print("Error: ", error)
                        return
                    }
                    
                    debugPrint("RESPONSE: ", receivedJson)
                    
                    let jsonResponse = JSON(receivedJson)
                    
                    self?.container?.performBackgroundTask { context in
                        for (_, jsonObject):(String, JSON) in jsonResponse {
                            print("Json: \(jsonObject)")
                            _ = try? User.findOrCreateUser(with: jsonObject, in: context)
                        }
                        try? context.save()
                        
                        DispatchQueue.main.async {
                            self?.refreshControl?.endRefreshing()
                        }
                    }
                    
//                    self?.messages.append(jsonMessage.dictionaryValue)
                    self?.tableView.reloadData()
                    
                }
                
                channel.onSubscribed = {
                    print("Subscribed")
                }
                
                channel.onUnsubscribed = {
                    print("Unsubscribed")
                }
                
                channel.onRejected = {
                    print("Rejected")
                }
            }
        }
        
        client.onDisconnected = {(error: Error?) in
            print("Disconnected!")
            print("Error: \(error)")
        }

    }
    

    // MARK: - UITableViewController

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.tableViewMessageCellIdentifier, for: indexPath)
        
        let messageRow = messages[indexPath.row]
        
        debugPrint(messageRow)
        
        return cell
    }
    
    // MARK: - CoreData
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

}
