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
        
        static let segueToLoginViewController: String = "Segue To LoginViewController"
        
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
                DonutServer.userId = Int(id)
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
        
        Alamofire.request(DonutServer.Constants.myUserInfoService,
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
    
    private func updateUI() {
        
        if let name = user?.name {
            nameTextField.text = name
        }
        
        if let category = user?.category {
            categoryTextField.text = category
        }
        
        if let picUrl = user?.url_profile_pic {
            let suapUrl = DonutServer.Constants.suapPrefix
            let url = URL(string: suapUrl.appending(picUrl))
            let data = try? Data(contentsOf: url!)
            let image = UIImage(data: data!)
            userImage.image = image!
        }
                
    }
    
    private func requestMyUserInfoIfAlreadyAuthenticated() {
        
        if DonutServer.isAuthenticated {
            requestMyUserInfoAsync(with: DonutServer.token!)
        } else {
            performSegueToLoginViewController()
        }
        
    }
    
    private func loadMyUserInfoIfIHaveUserId() {

        if let id = DonutServer.userId {
            if let context = container?.viewContext {
                self.user = User.findUserById(with: id, in: context)
            }
            requestMyUserInfoIfAlreadyAuthenticated()
        } else {
            requestMyUserInfoIfAlreadyAuthenticated()
        }

    }
    
    private func performSegueToLoginViewController() {
        performSegue(withIdentifier: Constants.segueToLoginViewController, sender: self)
    }
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadMyUserInfoIfIHaveUserId()
        
    }

    // MARK: - CoreData
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
}

