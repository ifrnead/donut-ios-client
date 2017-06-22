//
//  UserViewController.swift
//  Donut Client
//
//  Created by Allan Garcia on 09/06/17.
//  Copyright © 2017 Allan Garcia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData


class UserViewController: UITableViewController {
    
    // MARK: - Constants
    
    private struct Constants {
        
        static let serverPrefix: String = "http://10.123.1.128:3000"
        static let myUserInfoService: String = "\(serverPrefix)/api/users/me"
        static let suapPrefix: String = "http://suap.ifrn.edu.br"
        
        static let segueToLoginViewController: String = "Segue To LoginViewController"
        
        static let defaultsTokenKey: String = "tokenKey"
        static let defaultsUserIdKey: String = "userIdKey"
        
    }

    // MARK: - Outlets
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var nameTextField: UILabel!
    
    @IBOutlet weak var categoryTextField: UILabel!
    
    // MARK: - Actions

    
    
    // MARK: - Model
    
    private var user: User? {
        didSet {
            if let id = user?.id {
                userId = Int(id)
            }
            if user != nil {
                updateUI()
            }
        }
    }
    
    // MARK: - Network
    
    private func requestMyUserInfoAsync(with token: String) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)",
            "Accept": "application/json"
        ]
        
        Alamofire.request(Constants.myUserInfoService,
                          method: .get,
                          headers: headers)
            .validate(contentType: ["application/json"])
            .responseJSON { [weak self] response in
                
                switch response.result {
                    
                case .success(let value):
                    
                    debugPrint("Response: \(value)")
                    
                    let jsonResponse = JSON(value)
                    
                    if jsonResponse["id"].exists() {
                        
                        self?.container?.performBackgroundTask { context in
                            let user = try? User.findOrCreateUser(with: jsonResponse, in: context)
                            try? context.save()
                            
                            DispatchQueue.main.async {
                                self?.user = user
                            }
                            
                        }
                        
                    } else {
                        
                        // nao peguei os dados por algum motivo
                        
                    }
                    
                case .failure(let error):
                    
                    debugPrint("Error: \(error)")
                    
                    // servidor deu erro por algum motivo
                    
                }
                
        }
        
    }
    
    // MARK: - Private Implementation
    
    private var token: String? {
        return UserDefaults.standard.string(forKey: Constants.defaultsTokenKey)
    }
    
    private var isAuthenticated: Bool {
        return (token != nil) ? true : false
    }
    
    private var userId: Int? {
        get {
            return UserDefaults.standard.integer(forKey: Constants.defaultsUserIdKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.defaultsUserIdKey)
        }
    }
    
    private func updateUI() {
        
        if let name = user?.name {
            nameTextField.text = name
        }
        
        if let category = user?.category {
            categoryTextField.text = category
        }
        
        if let picUrl = user?.url_profile_pic {
            let suapUrl = Constants.suapPrefix
            let url = URL(string: suapUrl.appending(picUrl))
            let data = try? Data(contentsOf: url!)
            let image = UIImage(data: data!)
            userImage.image = image!
        }
                
    }
    
    private func performSegueToLoginViewController() {
        performSegue(withIdentifier: Constants.segueToLoginViewController, sender: self)
    }
    
    // MARK: - CoreData
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isAuthenticated {
            
            if let id = userId {
                
                if let context = container?.viewContext {
                    self.user = User.findUserById(with: id, in: context)
                }
                
                requestMyUserInfoAsync(with: token!)
                
            } else {
                
                requestMyUserInfoAsync(with: token!)
                
            }
            
        } else {
            
            performSegueToLoginViewController()
            
        }
        
    }
    
}
