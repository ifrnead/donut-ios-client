//
//  DonutViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 08/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit

class DonutViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var loggedOrLoginButton: UIButton!
 
    // MARK: - Persistency
    
    private var persistence = UserDefaults.standard
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let userLogged = persistence.bool(forKey: GlobalConstants.kUserLogged)
        if userLogged {
            if let userToken = persistence.string(forKey: GlobalConstants.kUserToken) {
                loggedOrLoginButton.setTitle("Logged", for: UIControlState.normal)
                print(userToken)
            }
        } else {
            performSegue(withIdentifier: GlobalConstants.kLoginSegue, sender: nil)
        }
        
    }
    
}

struct GlobalConstants {
    static let kUserLogged: String = "kUserLogged"
    static let kUserToken: String = "kUserToken"
    static let kLoginSegue: String = "kLoginSegue"
}
