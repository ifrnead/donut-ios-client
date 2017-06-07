//
//  DonutAuthViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 07/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit

class DonutAuthViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func login(_ sender: UIButton) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func forgot(_ sender: UIButton) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
