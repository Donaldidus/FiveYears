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


class DataService {
    
    lazy var DB_BASE = Database.database().reference()
    
    lazy var storage = Storage.storage()
    
    var maxImageSize: Int64 = 10 * 1024 * 1024
    
    private lazy var _REF_BASE = Database.database().reference()
    private lazy var _REF_MEMORIES = Database.database().reference().child("memories")
    private lazy var _REF_NOTIFICATIONS = Database.database().reference().child("notifications")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_MEMORIES: DatabaseReference {
        return _REF_MEMORIES
    }
    
    var REF_NOTIFICATIONS: DatabaseReference {
        return _REF_NOTIFICATIONS
    }
    
    func getMemory(forTimestamp timestamp: String? = nil, completionHandler: @escaping (MyMemory) -> Void) {
        var timestamp = timestamp
        if timestamp == nil {
            timestamp = String(Int(Date().timeIntervalSince1970))
        }
        // only consider memories until today
        REF_MEMORIES.queryEnding(atValue: nil, childKey: timestamp).queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
            let memory = self.extract(from: snapshot.children.allObjects[0] as! DataSnapshot)
            completionHandler(memory)
        })
    }
    
    /// Set the notification to seen in the database.
    ///
    /// - Parameter timestamp: timestamp of the notification
    func setNotificationAsSeen(timestamp: String) {
        REF_NOTIFICATIONS.child(timestamp).child("dismissed").setValue(true)
    }
    
    func image(for url: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        let imageRef = storage.reference(forURL: url)
        imageRef.getData(maxSize: maxImageSize, completion: completionHandler)
    }
    
    
    /// Extracts the data from a given Firebase Snapshot and assigns it to the text and images property.
    /// This will also load the images from the web. Make sure to call this function only if it's necessary.
    ///
    /// - Parameter snapshot: Snapshot incorporating the data.
    
    // completionHandler: @escaping (MyMemory?, Error?) -> Void)
    private func extract(from snapshot: DataSnapshot) -> MyMemory {
        let title = snapshot.childSnapshot(forPath: DataBaseMemoryKeys.title).value as? String ?? "No title"
        let text = snapshot.childSnapshot(forPath: DataBaseMemoryKeys.text).value as? String ?? "No text available."
        let timestamp = snapshot.key
        
        
        let imageSources = snapshot.childSnapshot(forPath: DataBaseMemoryKeys.images).children
        
        var images = [MyImage]()
        
        for source in imageSources {
            if let source = source as? DataSnapshot, let imageURL = source.value as? String {
                let fileName = timestamp + "-" + source.key
                // let image = MemoryImage(image: nil, webUrl: imageURL, fileName: fileName)
                let image = MyImage(webURL: imageURL, fileName: fileName)
                images.append(image)
            }
        }
        let memory = MyMemory(title: title, text: text, images: images, timestamp: timestamp)
        return memory
    }
}

struct MyMemory {
    init(title: String, text: String, images: [MyImage]?, timestamp: String) {
        self.title = title
        self.text = text
        self.images = images
        self.timestamp = timestamp
    }
    
    init(memory: Memory) {
        self.title = memory.title!
        self.text = memory.text!
        self.images = [MyImage]()
        for image in memory.images! {
            self.images?.append(MyImage(image: image as! Image))
        }
        self.timestamp = memory.timestamp!
    }
    
    var title: String
    var text: String
    var images: [MyImage]?
    var timestamp: String
}

struct MyImage {
    init(webURL: String, fileName: String) {
        self.webURL = webURL
        self.fileName = fileName
    }
    
    init(image: Image) {
        self.webURL = image.webURL!
        self.fileName = image.fileName!
    }
    
    var webURL: String
    var fileName: String
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
