//
//  Constants.swift
//  RealmBarcode
//
//  Created by David HM Spector on 3/24/18.
//  Copyright © 2018 Realm. All rights reserved.
//

import Foundation
struct Constants {
    

    // **** Realm Cloud Users:
    // **** Replace MY_INSTANCE_ADDRESS with the hostname of your cloud instance
    // **** e.g., "mycoolapp.us1.cloud.realm.io"
    // ****
    // ****
    // **** ROS On-Premises Users
    // **** Replace the AUTH_URL and REALM_URL strings with the
    // **** fully qualified versions of address of your ROS server, e.g.:
    // **** "http://127.0.0.1:9080" and "realm://127.0.0.1:9080"
    
    // Realm Cloud
    //static let MY_INSTANCE_ADDRESS = "127.0.0.1:9080" // <- update this
    //static let AUTH_URL  = URL(string: "https://\(MY_INSTANCE_ADDRESS)")!
    //static let REALM_URL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/Barcodes")!
    
    
    // On Prem
    static let ADMINTOKEN = "eyJhcHBfaWQiOiJpby5yZWFsbS5hdXRoIiwiaWRlbnRpdHkiOiJfX2FkbWluIiwiYWNjZXNzIjpbImRvd25sb2FkIiwidXBsb2FkIiwibWFuYWdlIl0sInNhbHQiOiJhYzMwMDlmYSJ9:Xymgj+EdHwlTJqnqf+SYdxrOXN3UkxtjRG8DeLjIMCXb/00JblePCp1Syf7ODqnXdZfwCOIF3mZnhzCxZDA7ubV/c+OKtGsMWUd7XrkV5jCcNIu9+jM1f/dqWkcl0zh++A3z3nqQgD5X9TQI+AoTvvhhBv4X3FzyRhbmC86+JdQqBn/wFoy5QtTuEjA/DaycdekXYtkdPuT1sgBFHDgqwdm6G4PtAURZKBO/MQOL0xk42cfI7lV6I+CATQUhaaROIoeAzESij245BS25bQRApuQEJgbaatq4LNKzI8ro+sx+60CKaeJPvL8mRKlN32AaHRavkOmpvjScn0ypMCB4eg=="
    static let AUTH_URL  = URL(string: "http://127.0.0.1:9080")!
    static let REALM_URL = URL(string: "realm://127.0.0.1:9080/Barcodes")!

}

