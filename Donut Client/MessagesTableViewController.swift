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
    
    @IBAction func send(_ sender: UIBarButtonItem) {
        
        if let messageText = messageTextField.text {
            
            sendMessageWith(text: messageText)
            messageTextField.text = ""
            
        }
        
    }
    
    // MARK: - Model
    
    var room: Room? {
        didSet {
            title = room?.title
            debugPrint("ROOM: ", room ?? "Not Setted.")
        }
    }
    
    private var messages: [Message] = []
    
    // MARK: - Network
    
    private var client: ActionCableClient!
    
    private var channel: Channel?
    
    // MARK: - Private Implementation
    
    func sendMessageWith(text: String) {
        guard let channel = channel else { return }
        // send message
        let roomIdentifier = Int((room?.id)!)
        if let error = channel.action("send_message", with: ["content": text, "room_id": roomIdentifier]) {
            debugPrint("ERROR: ", error)
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = ActionCableClient(
            url: URL(string: DonutServer.Constants.actionCableEndPoint)!
        )
        client.headers = [
            "token": DonutServer.token!
        ]
        client.connect()
        
        client.onConnected = { [weak self] in
            print("Connected!")
            
            let roomIdentifier = Int((self?.room?.id)!)
            self?.channel = self?.client.create(DonutServer.Constants.actionCableChannelClass,
                                                identifier: ["room_id": roomIdentifier],
                                                autoSubscribe: true,
                                                bufferActions: true)
            
            if let channel = self?.channel {
                
                channel.onReceive = { (receivedJson : Any?, error : Error?) in
                    
                    if error != nil {
                        debugPrint("ERROR: ", error!)
                        return
                    }
                    
                    debugPrint("RESPONSE: ", receivedJson ?? "")
                    
                    if receivedJson != nil {
                        
                        let jsonMessage = JSON(receivedJson!)["message"]
                        
                        if let context = self?.container?.viewContext {
                            context.perform {
                                let message = try? Message.findOrCreateMessage(with: jsonMessage, in: context)
                                try? context.save()
                                
                                self?.messages.append(message!)
                                self?.tableView.reloadData()
                            }
                        }
                        
                    }
                    
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
            
            if error != nil {
                debugPrint("ERROR: ", error!)
            }
            
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
        
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.content ?? ""
        
        return cell
    }
    
    // MARK: - CoreData
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

}
