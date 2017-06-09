//
//  LoginViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 09/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit

class LoginViewController: UITableViewController, UITextFieldDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Actions
    
    @IBAction func login(_ sender: UIButton) {
        
    }
    
    @IBAction func forgot(_ sender: UIButton) {
        
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

}
