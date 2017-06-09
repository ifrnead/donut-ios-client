//
//  User.swift
//  Donut Client
//
//  Created by Allan Garcia on 09/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import CoreData
import SwiftyJSON

class User: NSManagedObject {

    class func findOrCreateUser(with json: JSON, in context: NSManagedObjectContext) throws -> User {
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        request.predicate = NSPredicate(format: "id = %@", json["id"].intValue)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "User.findOrCreateUser -- database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let user = User(context: context)
        
        user.id = json["id"].int16Value
        user.enroll_id = json["enroll_id"].int16Value
        user.suap_id = json["suap_id"].int16Value
        user.username = json["username"].stringValue
        user.name = json["name"].stringValue
        user.fullname = json["fullname"].stringValue
        user.email = json["email"].stringValue
        user.url_profile_pic = json["url_profile_pic"].stringValue
        user.category = json["category"].stringValue
        user.token = json["token"].stringValue
        user.suap_token = json["suap_token"].stringValue
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        if let date = dateFormatter.date(from: json["suap_token_expiration_date"].stringValue) {
            user.suap_token_expiration_date = date as NSDate
        }
        if let date = dateFormatter.date(from: json["updated_at"].stringValue) {
            user.updated_at = date as NSDate
        }
        if let date = dateFormatter.date(from: json["created_at"].stringValue) {
            user.created_at = date as NSDate
        }

        return user
    }

}
