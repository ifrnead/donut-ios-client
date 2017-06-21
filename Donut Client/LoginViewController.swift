//
//  LoginViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 09/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit


class LoginViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Model
    
    private var token: String? {
        didSet {
            if token != nil {
                performSegue(withIdentifier: Constants.unwindSegueToUserViewController, sender: self)
            } else {
                headerLabel.text = "Sorry, but I can't login. Are you sure you using SUAP-ID credentials? Please try again."
            }
        }
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let unwindSegueToUserViewController: String = "Unwind To UserViewController"
    }

    // MARK: - Outlets
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Actions
    
    @IBAction func login(_ sender: UIButton) {
        
        requestLoginAsync()
        
    }
    
    @IBAction func forgot(_ sender: UIButton) {
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.unwindSegueToUserViewController {
            if let userViewController = segue.destination as? UserViewController {
                // do
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
    
    private func requestLoginAsync() {
        
        if let username = usernameTextField.text, let password = passwordTextField.text {
            
            DonutServer.standard.requestAuth(for: username, and: password) { [weak self] response in
                
                switch response {
                case .success(let token):
                    self?.token = token
                case .fail:
                    self?.token = nil
                }
                
            }
            
        }

    }

}
