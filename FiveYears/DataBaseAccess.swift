//
//  DataBaseAccess.swift
//  FiveYears
//
//  Created by Jan B on 23.07.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import UIKit
import CoreData

class DataBaseAccess {
    
    let imageFolder = "memoryimages"
    let imageType = ".png"
    
    let dataService = DataService()
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    // look for requested memory in the database and return it if it's not found return nil
    func memory(for timestamp: String? = nil, completionHandler: @escaping (MyMemory) -> Void) {
        // if timestamp is not nil check local database first
        if let timestamp = timestamp, let memory = try! Memory.memoryFor(timestamp: timestamp, in: container!.viewContext) {
            completionHandler(MyMemory(memory: memory))
            return
        } else {
            // fetch memory from the web
            dataService.getMemory(forTimestamp: timestamp, completionHandler: {[weak self] memory in
                // execute completionHandler
                completionHandler(memory)
                // save fetched memory to local database
                self?.container?.performBackgroundTask({ context in
                    _ = try? Memory.findOrCreate(memory: memory, in: context)
                    try? context.save()
                })
                return
            })
        }
    }
    
    
    // returns all UIImages stored in the directory of the timestamp,
    func image(named fileName: String, from webURL: String, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        // step 1: look for image in local file system
        do {
            var filePath = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            filePath.appendPathComponent(imageFolder + "/" + fileName + imageType)
            
            if FileManager.default.fileExists(atPath: filePath.path) {
                DispatchQueue.global(qos: .userInteractive).async {
                    let image = UIImage(contentsOfFile: filePath.path)
                    completionHandler(image, nil)
                }
                return
            } else {
                // step 2: not found in local file system -> retrieve image from webURL and save it to file system
                dataService.image(for: webURL, completionHandler: {[weak self] (data, error) in
                    if error != nil {
                        print(error.debugDescription)
                    } else {
                        if let image = UIImage(data: data!) {
                            completionHandler(image, nil)
                            DispatchQueue.global(qos: .background).async {
                                try? self?.save(image: image, named: fileName)
                            }
                        }
                    }
                })
            }
        } catch {
            completionHandler(nil, error)
        }
    }
    
    private func save(image: UIImage, named fileName: String) throws {
        // navigate to cache directory
        do {
            var cacheDir = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            cacheDir.appendPathComponent(imageFolder)
            // create directory
            try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
                do {
                if let pngImage = UIImagePNGRepresentation(image) {
                    let fileDir = cacheDir.appendingPathComponent(fileName + imageType)
                    try pngImage.write(to: fileDir)
                }
            }
            
        } catch {
            throw error
        }
    }
}
