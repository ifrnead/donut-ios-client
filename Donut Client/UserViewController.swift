//
//  UserViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 09/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit
import CoreData

class UserViewController: UITableViewController {
    
    // MARK: - Constants
    
    struct Constants {
        static let kUserLogged: String = "kUserLogged"
    }

    // MARK: - Outlets
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var nameTextField: UILabel!
    
    @IBOutlet weak var categoryTextField: UILabel!
    
    // MARK: - Persistency
    
    private var persistence = UserDefaults.standard
    
    // MARK: - CoreData
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segueToLoginViewControllerIfNotLogged()
    }
    
    // MARK: - Private Implementation
    
    private func segueToLoginViewControllerIfNotLogged() {
        let userLogged = persistence.bool(forKey: Constants.kUserLogged)
        if !userLogged {
            performSegue(withIdentifier: "Show Login", sender: nil)
        }

    }
}
