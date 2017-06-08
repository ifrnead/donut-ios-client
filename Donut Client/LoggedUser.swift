//
//  LoggedUser.swift
//  Donut Client
//
//  Created by Allan Garcia on 08/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import Foundation
import SwiftyJSON

struct LoggedUser {
    
    var id: Int?
    
    var enrollId: Int?
    
    var suapId: Int?
    
    var userName: String?
    
    var name: String?
    
    var fullName: String?
    
    var email: String?
    
    var urlProfilePicture: String?
    
    var category: String?
    
    var token: String?
    
    var suapToken: String?
    
    var suapTokenExpirationDate: String?
    
    var updatedAt: String?
    
    var createdAt: String?
    
    static func create(with json: JSON) -> LoggedUser {
        let newLoggedUser = LoggedUser(id: json["id"].intValue,
                                       enrollId: json["enroll_id"].intValue,
                                       suapId: json["suap_id"].intValue,
                                       userName: json["username"].stringValue,
                                       name: json["name"].stringValue,
                                       fullName: json["fullname"].stringValue,
                                       email: json["email"].stringValue,
                                       urlProfilePicture: json["url_profile_pic"].stringValue,
                                       category: json["category"].stringValue,
                                       token: json["token"].stringValue,
                                       suapToken: json["suap_token"].stringValue,
                                       suapTokenExpirationDate: json["suap_token_expiration_date"].stringValue,
                                       updatedAt: json["updated_at"].stringValue,
                                       createdAt: json["created_at"].stringValue)
        return newLoggedUser
    }
    
}
