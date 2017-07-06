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

        // put any constants here
        
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
    
    // FIXME: this should be on DonutServer struct
    private var token: String? {
        didSet {
            UserDefaults.standard.set(token, forKey: DonutServer.Constants.defaultsTokenKey)
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
            
            Alamofire.request(DonutServer.Constants.loginService,
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseJSON { [weak self] response in
                    
                    switch response.result {

                    case .success(let data):
                        
                        debugPrint("SUCCESS: ", data)
                        
                        let json = JSON(data)
                        
                        self?.token = json["token"].stringValue
                        
                    case .failure(let error):
                        
                        debugPrint("ERROR: ", error)
                        
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
