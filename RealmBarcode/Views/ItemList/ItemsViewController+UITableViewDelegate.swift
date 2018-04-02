//
//  ItemsViewController+UITableViewDelegate.swift
//  
//
//  Created by David HM Spector on 3/23/18.
//

import Foundation
import UIKit
extension ItemsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetailSegue", sender: nil)
    }
}
