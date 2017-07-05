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
        static let serverPrefix: String = "http://10.123.1.34:3000"
        static let loginService: String = "\(serverPrefix)/api/auth"
        static let listUsersService: String = "\(serverPrefix)/api/users"
        static let listRoomsService: String = "\(serverPrefix)/api/rooms"
        static let myUserInfoService: String = "\(serverPrefix)/api/users/me"

        static let actionCableEndPoint: String = "ws://10.123.1.34:3000/cable"
        static let actionCableChannelClass: String = "ChatRoomsChannel"
        
        static let suapPrefix: String = "http://suap.ifrn.edu.br"
        
        static let defaultsTokenKey: String = "tokenKey"
        static let defaultsUserIdKey: String = "userIdKey"

    }
    
    static var token: String? {
        return UserDefaults.standard.string(forKey: Constants.defaultsTokenKey)
    }
    
    static var isAuthenticated: Bool {
        return (token != nil) ? true : false
    }
    
    static var userId: Int? {
        get {
            return UserDefaults.standard.integer(forKey: Constants.defaultsUserIdKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.defaultsUserIdKey)
        }
    }

    
}
