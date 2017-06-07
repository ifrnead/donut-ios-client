//
//  DonutAuthViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 07/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit

class DonutAuthViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func login(_ sender: UIButton) {
        resignFirstResponder()
    }
    
    @IBAction func forgot(_ sender: UIButton) {
        resignFirstResponder()
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
}
