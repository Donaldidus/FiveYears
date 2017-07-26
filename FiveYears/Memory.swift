//
//  Memory.swift
//  FiveYears
//
//  Created by Jan B on 23.07.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import UIKit
import CoreData

class Memory: NSManagedObject {
    class func memoryFor(timestamp: String, in context: NSManagedObjectContext) throws -> Memory? {
        let request: NSFetchRequest<Memory> = Memory.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp = %@", timestamp)
        
        do {
            let memories = try context.fetch(request)
            if memories.count > 0 {
                assert(memories.count == 1, "Memory.findeOrCreate -- database inconsistency")
                return memories[0]
            }
            return nil
        } catch {
            throw error
        }
    }
    
    class func findOrCreate(memory: Memory, in context: NSManagedObjectContext) throws -> Memory {
        let request: NSFetchRequest<Memory> = Memory.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp = %@", memory.timestamp!)
        
        do {
            let memories = try context.fetch(request)
            if memories.count > 0 {
                assert(memories.count == 1, "Memory.findeOrCreate -- database inconsistency")
                return memories[0]
            }
        } catch {
            throw error
        }
        
        let newMemory = Memory(context: context)
        newMemory.timestamp = memory.timestamp
        newMemory.title = memory.title
        newMemory.text = memory.text
        if let images = memory.images {
            for image in images {
                if let image = image as? Image {
                    try! newMemory.images?.adding(Image.findOrCreate(image: image, for: memory, in: context))
                }
            }
        }
        return newMemory
    }
}
