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
            if loggedUser != nil {
                print("Usuário autenticado com sucesso!")
                
                persistence.set(true, forKey: GlobalConstants.kUserLogged)
                persistence.set(loggedUser!.token, forKey: GlobalConstants.kUserToken)
                persistence.synchronize()
                
                presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Persistency
    
    private var persistence = UserDefaults.standard
    
    // MARK: - Constants
    
    private struct Constants {
        static let loggedUserKey: String = "loggedUser"
        static let prefix: String = "http://localhost:3000"
        static let loginService: String = "\(prefix)/users/sign_in"
    }
    
    // MARK: - Application Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let loggedUserFromPersistence = persistence.object(forKey: Constants.loggedUserKey) {
            if let myLoggedUser = loggedUserFromPersistence as? LoggedUser {
                print(myLoggedUser)
            }
        }
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
            .validate(contentType: ["application/json"])
            .responseJSON { [weak self] response in
                
                switch response.result {
                    
                case .success(let value):
                    
                    self?.loggedUser = LoggedUser.create(with: JSON(value))
                    
                case .failure(let error):
                    
                    self?.loggedUser = nil
                    
                    print("Error: \(error)")
                    
                }
        
        }
        
    }
    
}
