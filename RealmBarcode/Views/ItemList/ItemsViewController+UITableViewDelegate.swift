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
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.confirmDelete(forRowAt: indexPath)
        }
    }
    
    
    // MARK: Utilities
    func confirmDelete(forRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: NSLocalizedString("Delete Product?", comment: "Delete Product"),
                                      message: NSLocalizedString("The item will be permanently deleted", comment: "effects warning"),
                                      preferredStyle: .alert)
        
        // Delete button
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete Task", comment: "delete"), style: .default) { (action:UIAlertAction!) in
            try! self.realm?.write {
                self.realm?.delete(self.items![indexPath.row])
            }
        }
        alert.addAction(deleteAction)
        
        // Cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped");
        }
        alert.addAction(cancelAction)
        
        // Present Dialog message
        present(alert, animated: true, completion:nil)
        
    }
} // of ItemsViewController - UITableViewDelegate
