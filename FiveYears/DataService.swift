//
//  DataService.swift
//  FiveYears
//
//  Created by Jan B on 29.04.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage


let DB_BASE = FIRDatabase.database().reference()

let storage = FIRStorage.storage()

class DataService {
    
    static let ds = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_MEMORIES = DB_BASE.child("memories")
    private var _REF_NOTIFICATIONS = DB_BASE.child("notifications")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_MEMORIES: FIRDatabaseReference {
        return _REF_MEMORIES
    }
    
    var REF_NOTIFICATIONS: FIRDatabaseReference {
        return _REF_NOTIFICATIONS
    }
}

struct DataBaseKeys {
    static let title = "title"
    static let text = "text"
    static let images = "images"
}

struct DataBaseNotificationKeys {
    static let message = "message"
    static let image = "image"
    static let dismissed = "dismissed"
}
