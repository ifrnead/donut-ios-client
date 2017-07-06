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
    
    private var user: User? { didSet { updateUI() } }
    
    // MARK: - Network
    
    private func requestMyUserInfoAsync(with token: String) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)",
            "Accept": "application/json"
        ]
        
        Alamofire.request(DonutServer.Constants.myUserInfoService,
                          method: .get,
                          headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { [weak self] response in
                
                switch response.result {
                    
                case .success(let data):
                    
                    debugPrint("SUCCESS: ", data)
                    
                    let json = JSON(data)

                    self?.container?.performBackgroundTask { context in
                        let user = try? User.findOrCreateUser(with: json, in: context)
                        try? context.save()
                        
                        let userId = Int((user?.id)!)
                        DonutServer.userId = userId
                        DispatchQueue.main.async {
                            self?.loadUser(with: userId)
                        }
                        
                    }
                    
                case .failure(let error):
                    
                    debugPrint("ERROR: ", error)
                    
                }
                
        }
        
    }
    
    // MARK: - Private Implementation
    
    private func updateUI() {
        
        nameTextField.text = user?.name!
        categoryTextField.text = user?.category!
        
        if let picUrl = user?.url_profile_pic {
            let suapUrl = DonutServer.Constants.suapPrefix
            if let url = URL(string: suapUrl.appending(picUrl)) {
                if let data = try? Data(contentsOf: url) {
                    userImage.image = UIImage(data: data)
                }
            }
        } else {
            userImage.image = nil
        }
                
    }
    
    private func loadUser(with id: Int) {
        if let context = container?.viewContext {
            context.perform {
                self.user = User.findUserById(with: id, in: context)
            }
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
            loadUser(with: id)
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

