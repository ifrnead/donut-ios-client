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
    
    // MARK: - Model
    
    var currentUserId: Int {
        get {
            return UserDefaults.standard.integer(forKey: Constants.defaultsUserID)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.defaultsUserID)
        }
    }
    
    var currentUser: User? {
        didSet {
            if currentUser != nil {
                if let id = currentUser?.id {
                    currentUserId = Int(id)
                }
            }
        }
    }
    
    // MARK: - Constants
    
    struct Constants {
        static let defaultsUserID: String = "defaultsUserID"
        static let segueToLoginViewController: String = "Segue To LoginViewController"
    }

    // MARK: - Outlets
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var nameTextField: UILabel!
    
    @IBOutlet weak var categoryTextField: UILabel!
    
    // MARK: - CoreData
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        determineIfIHaveCurrentUser()
                
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // prepare for segue
    }
    
    @IBAction func unwind(from segue: UIStoryboardSegue) {
        // do stuff
    }
    
    // MARK: - Private Implementation
    
    private func determineIfIHaveCurrentUser() {
        
        if currentUser != nil {
            
            // I'm logged!
            
        } else {
            
            if currentUserId != 0 {
                
                // Try to get from database if I was logged before
                
                if let context = container?.viewContext {
                    currentUser = User.findUserById(with: currentUserId, in: context)
                    if currentUser == nil {
                        performSegueToLoginViewController()
                    }
                }
                
            } else {
                
                // I never logged before
                
                performSegueToLoginViewController()
                
            }
            
        }
    }
    
    private func performSegueToLoginViewController() {
        performSegue(withIdentifier: Constants.segueToLoginViewController, sender: self)
    }

}
