//
//  Message.swift
//  Donut Client
//
//  Created by Allan Garcia on 04/07/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import CoreData
import SwiftyJSON


class Message: NSManagedObject {

    class func findMessageById(with id: Int, in context: NSManagedObjectContext) -> Message? {
        
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "id = %d", id
        )
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Message.findMessageById -- database inconsistency")
                return matches[0] // Found user
            }
        } catch {
            // do nothing yet
        }
        
        return nil
    }
    
    class func findOrCreateMessage(with json: JSON, in context: NSManagedObjectContext) throws -> Message {
        
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "id = %d",
            json["id"].intValue
        )
        
        let message: Message
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Message.findOrCreateMessage -- database inconsistency")
                message = matches[0] // Existing message
            } else {
                message = Message(context: context) // New message
            }
        } catch {
            throw error
        }
        
        message.id = json["id"].int64Value
        message.content = json["content"].stringValue
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        if let date = dateFormatter.date(from: json["updated_at"].stringValue) {
            message.updated_at = date as NSDate
        }
        if let date = dateFormatter.date(from: json["created_at"].stringValue) {
            message.created_at = date as NSDate
        }
        
        message.room = Room.findRoomById(with: json["room_id"].intValue, in: context)
        message.sender = User.findUserById(with: json["user_id"].intValue, in: context)
        
        return message
    }
    
}
