//
//  Image.swift
//  FiveYears
//
//  Created by Jan B on 23.07.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import UIKit
import CoreData

class Image: NSManagedObject {
    
    class func findOrCreate(image: MyImage, for memory: MyMemory, in context: NSManagedObjectContext) throws -> Image {
        let request: NSFetchRequest<Image> = Image.fetchRequest()
        request.predicate = NSPredicate(format: "webURL = %@", image.webURL)
        
        do {
            let images = try context.fetch(request)
            if images.count > 0 {
                assert(images.count == 1, "Image.findeOrCreate -- database inconsistency")
                return images[0]
            }
        } catch {
            throw error
        }
        
        let newImage = Image(context: context)
        newImage.fileName = image.fileName
        newImage.webURL = image.webURL
        newImage.memory = try? Memory.findOrCreate(memory: memory, in: context)
        return newImage
    }
    
}
