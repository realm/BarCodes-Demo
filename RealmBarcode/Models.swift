//
//  Models.swift
//  RealmBarcode
//
//  Created by David HM Spector on 3/23/18.
//  Copyright © 2018 Realm. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var id = "" // this is the string scanned from the UPC or QRCode
    @objc dynamic var creationDate: Date?
    @objc dynamic var lastUpdated: Date?
    @objc dynamic var productDescription = ""
    
    // Initializers, accessors & cet.
    override static func primaryKey() -> String? {
        return "id"
    }
    
}   // Item
