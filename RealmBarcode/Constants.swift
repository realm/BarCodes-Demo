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
    
    //
    // If you are running this demo from your local machine you can
    // use the "LocalIP" addresss mecahanism --- this is a local file
    // generatred at compile time tht writes the current default IP address for
    // the local machine to a file which is then used to allow a hardware device
    // to speak to the local ROS server.
    //

    
    // for an "on premises" ROS, replace replace "\(localIPAddress)" with the address of your ROS server
    static let AUTH_URL  = URL(string: "http://\(localIPAddress):9080")!
    static let REALM_URL = URL(string: "realm://\(localIPAddress):9080/Barcodes")!

}

