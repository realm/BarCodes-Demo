//
//  ItemsViewController.swift
//  RealmBarcode
//
//  Created by David HM Spector on 3/23/18.
//  Copyright © 2018 Realm. All rights reserved.
//
import Foundation
import UIKit
import RealmSwift



class ItemsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var notifictionToken: NotificationToken?
    var realm: Realm?
    var items: Results<Item>?
    var notificationToken: NotificationToken?

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // In a simplified Realm Cloud version you might not even need a login controller --- so this is another way to
        // log in....
        
        // A Nickname:
        //      let usernameCredentials = SyncCredentials.nickname("SomeUser", isAdmin: true)
        
        // A Real user credential
        //      let usernameCredentials = SyncCredentials.usernamePassword(username: "username", password: "password")
        
        // An auth token
        let credentials = SyncCredentials.nickname("david", isAdmin: true)
        
        SyncUser.logIn(with: credentials, server: Constants.AUTH_URL) { user, error in
            if let user = user {
                // can now open a synchronized Realm with this user
                let syncConfig = SyncConfiguration(user: user, realmURL: Constants.REALM_URL)
                self.realm = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig))
                self.items = self.realm?.objects(Item.self).sorted(byKeyPath: "lastUpdated", ascending: false)
                
            } else if let error = error {
                // handle error
                print("Error logging in: \(error.localizedDescription)")
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

