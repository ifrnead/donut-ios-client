//
//  DonutAuthViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 07/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DonutAuthViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Model
    
    var loggedUser: LoggedUser? {
        didSet {
            print("Usuário autenticado com sucesso!")
            //            let alert = UIAlertController(title: "Usuário autenticado", message: "O usuário foi autenticado com sucesso", preferredStyle: .alert)
            //            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let prefix: String = "http://10.123.1.13:3000"
        static let loginService: String = "\(prefix)/users/sign_in"
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Actions
    
    @IBAction func login(_ sender: UIButton) {
        
        resignFirstResponderFromAllInputs()
        
        requestLogin()
        
    }
    
    @IBAction func forgot(_ sender: UIButton) {
        
        resignFirstResponderFromAllInputs()
        
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Private implementation
    
    private func resignFirstResponderFromAllInputs() {
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
    }
    
    private func requestLogin() {
        
        let parameters: Parameters = [
            "user": [
                "username": usernameTextField.text,
                "password": passwordTextField.text
            ]
        ]
        
        Alamofire.request(Constants.loginService,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { [weak self] response in
                
                switch response.result {
                    
                case .success(let value):
                    
                    let json = JSON(value)
                    
                    self?.loggedUser = LoggedUser.create(with: json)
                    
                case .failure(let error):
                    
                    print("Error: \(error)")
                    
                }
                
            }
            .responseString { response in
                switch response.result {
                case .success(let value):
                    
                    print("response string value on sucess: \(value)")
                    
                case .failure(let error):
                    
                    print("response string value on failure: \(error)")
                    
                    print("Response: \(response)")
                    
                    print("Result: \(response.result)")
                    
                }
        }
        
    }
    
    
}
