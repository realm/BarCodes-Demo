//
//  ItemDetailViewController.swift
//  RealmBarcode
//
//  Created by David HM Spector on 3/23/18.
//  Copyright © 2018 Realm. All rights reserved.
//
import Foundation
import UIKit

import Eureka
import RealmSwift

class ItemDetailViewController: FormViewController {
    var realm: Realm?
    var itemId = "" // ensure we don't crash if somehow we never get the id
    var itemRecord: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Product Details", comment: "Product Details")
        itemRecord = realm?.object(ofType: Item.self, forPrimaryKey: itemId)
        form = createForm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    func createForm() -> Form {
        
        let form = Form()
        
        form +++ Section()
            <<< LabelRow(NSLocalizedString("Barcode Value", comment: "Barcode Value")){ row in
                row.title = NSLocalizedString("Barcode Value", comment: "Barcode Value")
                row.value = itemRecord?.id
                row.disabled = true
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                })
        
            <<< LabelRow(NSLocalizedString("Product Description", comment: "Product Description")){ row in
                row.title = NSLocalizedString("Product Description", comment: "Product Description")
                    row.value = self.itemRecord?.productDescription
                row.disabled = false
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                }).onChange({ (row) in
                    try! self.realm?.write {
                        self.itemRecord?.productDescription = row.value ?? ""
                    }
                })
        
            <<< DateRow(){ row in
                row.disabled = true
                row.title = NSLocalizedString("Creation Date", comment: "Creation Date")
                row.value = itemRecord?.lastUpdated ?? Date()
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                row.dateFormatter = formatter
                }
        
        
            <<< DateRow(){ row in
                row.disabled = true
                row.title = NSLocalizedString("Last Upated", comment: "Last Upated")
                row.value = itemRecord?.creationDate ?? Date()
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                row.dateFormatter = formatter
        }

        return form
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
