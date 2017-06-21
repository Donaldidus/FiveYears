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


let DB_BASE = Database.database().reference()

let storage = Storage.storage()

class DataService {
    
    static let ds = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_MEMORIES = DB_BASE.child("memories")
    private var _REF_NOTIFICATIONS = DB_BASE.child("notifications")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_MEMORIES: DatabaseReference {
        return _REF_MEMORIES
    }
    
    var REF_NOTIFICATIONS: DatabaseReference {
        return _REF_NOTIFICATIONS
    }
    
    /// Set the notification to seen in the database.
    ///
    /// - Parameter timestamp: timestamp of the notification
    func setNotificationAsSeen(timestamp: String) {
        REF_NOTIFICATIONS.child(timestamp).child("dismissed").setValue(true)
    }
}

// the keys to access the data in the firebase database
struct DataBaseMemoryKeys {
    static let title = "title"
    static let text = "text"
    static let images = "images"
}

struct DataBaseNotificationKeys {
    static let message = "message"
    static let image = "image"
    static let dismissed = "dismissed"
}
