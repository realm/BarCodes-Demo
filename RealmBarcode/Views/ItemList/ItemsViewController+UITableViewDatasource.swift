//
//  ItemsViewController+UITableViewDatasource.swift
//  RealmBarcode
//
//  Created by David HM Spector on 3/23/18.
//  Copyright © 2018 Realm. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift


extension ItemsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = self.items![indexPath.row]
        cell.textLabel?.text = "product ID: \(item.id)"
        cell.detailTextLabel?.text = item.productDescription
        return cell
    }
    
} // ItemsViewController
