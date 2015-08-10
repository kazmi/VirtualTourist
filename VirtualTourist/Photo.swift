//
//  Photo.swift
//  VirtualTourist
//
//  Created by Sulaiman Azhar on 8/10/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)

class Photo: NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let Title = "title"
        static let ImagePath = "imagePath"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var imagePath: String?
    @NSManaged var location: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.ID] as! Int
        title = dictionary[Keys.Title] as! String
        imagePath = dictionary[Keys.ImagePath] as? String
        
    }
    
}
