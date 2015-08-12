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
        static let ImageURL = "url_m"
    }
    
    @NSManaged var id: String?
    @NSManaged var imageURL: String?
    @NSManaged var location: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.ID] as? String
        imageURL = dictionary[Keys.ImageURL] as? String
        
    }
    
}
