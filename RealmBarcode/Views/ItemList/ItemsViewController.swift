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
        
        navigationItem.title = NSLocalizedString("Item Inventory", comment:"Item Inventory")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ItemCell")
        
        // In a simplified Realm Cloud version you might not even need a login controller --- so this is another way to
        // log in....
        
        // A Nickname:
        //      let usernameCredentials = SyncCredentials.nickname("SomeUser", isAdmin: true)
        
        // A Real user credential
        //      let usernameCredentials = SyncCredentials.usernamePassword(username: "username", password: "password")
        
        if SyncUser.current == nil { /// no current user - log in our Nickname account...
            let credentials = SyncCredentials.nickname("david", isAdmin: true)
            SyncUser.logIn(with: credentials, server: Constants.AUTH_URL) { user, error in
                if let user = user {
                    // can now open a synchronized Realm with this user
                    let syncConfig = SyncConfiguration(user: user, realmURL: Constants.REALM_URL)
                    self.realm = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig))
                    self.items = self.realm?.objects(Item.self).sorted(byKeyPath: "lastUpdated", ascending: false)
                    self.notificationToken = self.notifcationTokenForCollection(self.items)
                } else if let error = error {
                    // handle error
                    print("Error logging in: \(error.localizedDescription)")
                }
            }
        } else { // aready logged in; just fetch the item list & setup notificaitons
            let syncConfig = SyncConfiguration(user: SyncUser.current!, realmURL: Constants.REALM_URL)
            self.realm = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig))
            self.items = self.realm?.objects(Item.self).sorted(byKeyPath: "lastUpdated", ascending: false)
            self.notificationToken = self.notifcationTokenForCollection(self.items)
        }
        
    } // viewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
        if self.notifictionToken == nil {
            notificationToken = self.notifcationTokenForCollection(items)
        }
        tableView.reloadData()
    } // viewWillAppear
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // When this controller is disposed, of we want to make sure we stop the notifications
    deinit {
        notificationToken?.invalidate()
    }
    
    
    // MARK: Utilities
    
    fileprivate func notifcationTokenForCollection(_ collection: Results<Item>?) -> NotificationToken? {
        guard collection != nil else {
            return nil
        }
        
        return collection?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    } //notifcationTokenForCollection
    
} // ItemsViewController
