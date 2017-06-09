//
//  LoginViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 09/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class LoginViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Model
    
    var currentUser: User? {
        didSet {
            if currentUser != nil {
                performSegue(withIdentifier: Constants.unwindSegueToUserViewController, sender: self)
            } else {
                print("Login falhou... criar UI para isso")
            }
        }
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let prefix: String = "http://localhost:3000"
        static let loginService: String = "\(prefix)/users/sign_in"
        static let unwindSegueToUserViewController: String = "Unwind To UserViewController"
    }

    // MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - CoreData
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    // MARK: - Actions
    
    @IBAction func login(_ sender: UIButton) {
        
        requestLogin()
        
    }
    
    @IBAction func forgot(_ sender: UIButton) {
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.unwindSegueToUserViewController {
            if let userViewController = segue.destination as? UserViewController {
                userViewController.currentUser = currentUser
            }
        }
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
                    
                    self?.container?.performBackgroundTask { context in
                        do {
                            self?.currentUser = try User.findOrCreateUser(with: JSON(value), in: context)
                            try context.save()
                        } catch let error {
                            print("Error: \(error)")
                        }
                    }
                                        
                case .failure(let error):
                    
                    self?.currentUser = nil
                    
                    print("Error: \(error)")
                    
                }
                
        }
        
    }

}
