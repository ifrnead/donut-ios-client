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
import ActionCableClient


class MessagesTableViewController: UITableViewController {

    // MARK: - Constants
    
    private struct Constants {
        
        static let tableViewMessageCellIdentifier: String = "Message Cell"
        
    }
    
    // MARK: - Outlets
    
    
    
    // MARK: - Actions
    
    
    
    // MARK: - Model
    
    var room: Room?
    
    private var messages: [Dictionary<String, String>]?
    
    private var client: ActionCableClient!
    
    private var channel: Channel?
    
    // MARK: - Network
    
    
    
    // MARK: - Private Implementation
    
    func send(_ sender: Any) {
        guard let channel = channel else { return }
        // send message
        let random = arc4random() % 10
        if let error = channel.action("send_message", with: ["content": "hello: " + String(random), "room_id": 6]) {
            print("Error: ", error)
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = ActionCableClient(url: URL(string: "ws://localhost:3000/cable?token=9b6b21494b57303099ff9237bd1776dfbac7bbc6d46adf97b863527f9b53dd2dbf3a54a07edd5da8565cf244ecd940858edf2a17f97594a5e8cabf79ef29a8bf")!)
        client.connect()
        
        client.onConnected = {
            print("Connected!")
            
            self.channel = self.client.create("ChatRoomsChannel", identifier: ["room_id": 6])
            
            if let channel = self.channel {
                channel.onReceive = { (JSON : Any?, error : Error?) in
                    // receive message
                    if let json = JSON {
                        print("Received: ", json)
                    }
                    if let error = error {
                        print("Received: ", error)
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
        }

    }
    

    // MARK: - UITableViewController

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

}
