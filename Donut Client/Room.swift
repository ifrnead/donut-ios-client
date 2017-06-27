//
//  Room.swift
//  Donut Client
//
//  Created by Allan Garcia on 27/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import CoreData
import SwiftyJSON


class Room: NSManagedObject {
    
    class func findRoomById(with id: Int, in context: NSManagedObjectContext) -> Room? {
        
        let request: NSFetchRequest<Room> = Room.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "id = %d", id
        )
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Room.findRoomById -- database inconsistency")
                return matches[0] // Found user
            }
        } catch {
            // do nothing yet
        }
        
        return nil
    }

    class func findOrCreateRoom(with json: JSON, in context: NSManagedObjectContext) throws -> Room {
        
        let request: NSFetchRequest<Room> = Room.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "id = %d",
            json["id"].intValue
        )
        
        let room: Room
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Room.findOrCreateRoom -- database inconsistency")
                room = matches[0] // Existing room
            } else {
                room = Room(context: context) // New room
            }
        } catch {
            throw error
        }
        
        room.id = json["id"].int64Value
        room.suap_id = json["suap_id"].int64Value
        room.semester = json["semester"].int64Value
        room.title = json["title"].stringValue
        room.curricular_component = json["curricular_component"].stringValue
        room.year = json["year"].int64Value
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        if let date = dateFormatter.date(from: json["updated_at"].stringValue) {
            room.updated_at = date as NSDate
        }
        if let date = dateFormatter.date(from: json["created_at"].stringValue) {
            room.created_at = date as NSDate
        }
        
        return room
    }
    
}
