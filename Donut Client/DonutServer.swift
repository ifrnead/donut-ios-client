//
//  DonutServer.swift
//  Donut Client
//
//  Created by Allan Garcia on 27/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import Foundation


struct DonutServer {
    
    struct Constants {
        static let serverPrefix: String = "http://localhost:3000"
        static let listRoomsService: String = "\(serverPrefix)/api/rooms"
        
        static let defaultsTokenKey: String = "tokenKey"

    }
    
    static var token: String? {
        return UserDefaults.standard.string(forKey: Constants.defaultsTokenKey)
    }
    
    static var isAuthenticated: Bool {
        return (token != nil) ? true : false
    }

    
    
}
