//
//  DonutServer.swift
//  Donut Client
//
//  Created by Allan Garcia on 20/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


enum DonutServerResponse {
    case success(String)
    case fail(String)
}


class DonutServer {
    
    // MARK: - Singleton

    static let standard = DonutServer()
    
    // MARK: - Constants

    private struct Constants {
        static let serverPrefix: String = "http://localhost:3000"
        static let loginService: String = "\(serverPrefix)/api/auth"
        static let myUserInfoService: String = "\(serverPrefix)/api/users/me"
    }
    
    // MARK: - Properties
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "tokenKey")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "tokenKey")
        }
    }
    
    var isAuthenticated: Bool {
        if token != nil {
            return true
        } else {
            return false
        }
    }
    
    var lastMessage: String?
    
    // MARK: - API
    
    func requestAuth(for username: String, and password: String, with completionHandler: @escaping (DonutServerResponse) -> Void) {
        
        let parameters: Parameters = [
            "user": [
                "username": username,
                "password": password
            ]
        ]
        
        Alamofire.request(Constants.loginService,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .validate(contentType: ["application/json"])
            .responseJSON { [weak self] response in
                
                switch response.result {
                
                case .success(let value):
                    
                    debugPrint("Response: \(value)")

                    let jsonResponse = JSON(value)
                    
                    if let token = jsonResponse["token"].string {
                        self?.token = token
                        
                        completionHandler(.success(token))
                        
                    } else {
                        let message = jsonResponse["message"].stringValue
                        self?.lastMessage = message
                        self?.token = nil
                        
                        completionHandler(.fail(message))
                        
                    }
                    
                case .failure(let error):
                    
                    debugPrint("Error: \(error)")

                    let message = "unknown error"
                    self?.lastMessage = message
                    self?.token = nil
                    
                    completionHandler(.fail(message))
                    
                }
                
        }
        
    }
    
    func requestMyUserInfo() {
        
    }
    
}
