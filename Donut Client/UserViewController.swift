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
    
    var currentUser: User? {
        didSet {
            
            print(currentUser?.id)
            print(currentUser?.name)

            print(currentUser ?? "currentUser is nil")
            
            
            if currentUser != nil {
                UserDefaults.standard.set(currentUser?.id, forKey: Constants.kCurrentUserId)
            }
        }
    }
    
    // MARK: - Constants
    
    struct Constants {
        static let kCurrentUserId: String = "kCurrentUserId"
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
        
        let currentUserId = UserDefaults.standard.integer(forKey: Constants.kCurrentUserId)
        
        if currentUser != nil {
            
            // I'm logged!
            
        } else if currentUserId != 0 {
            
            // Try to get from database if I was logged before
            
            if let context = container?.viewContext {
                currentUser = User.findUserById(with: currentUserId, in: context)
                if currentUser == nil {
                    performSegue(withIdentifier: Constants.segueToLoginViewController, sender: nil)
                }
            }
            
        } else {
            
            // I never logged before
            
            performSegue(withIdentifier: Constants.segueToLoginViewController, sender: nil)

        }
    }

}
