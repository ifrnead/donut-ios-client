//
//  LoginViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 09/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class LoginViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Constants
    
    private struct Constants {
    
        static let serverPrefix: String = "http://localhost:3000"
        static let loginService: String = "\(serverPrefix)/api/auth"
        
        static let defaultsTokenKey: String = "tokenKey"
        
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Actions
    
    @IBAction func login(_ sender: UIButton) {
        
        requestAuthAsync()
        
    }
    
    @IBAction func forgot(_ sender: UIButton) {
        
    }
    
    // MARK: - Model
    
    private var token: String? {
        didSet {
            UserDefaults.standard.set(token, forKey: Constants.defaultsTokenKey)
            if token != nil {
                presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                headerLabel.text = "Sorry, but I can't login. Are you sure you using SUAP-ID credentials? Please try again."
            }
        }
    }
    
    // MARK: - Network
    
    private func requestAuthAsync() {
        
        if let username = usernameTextField.text, let password = passwordTextField.text {
            
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
                            
                        } else {
                            
                            self?.token = nil

                        }
                        
                    case .failure(let error):
                        
                        debugPrint("Error: \(error)")
                        
                        self?.token = nil
                        
                    }
                    
            }
            
        }
        
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }

}
