//
//  Meta.swift
//  VirtualTourist
//
//  Created by Sulaiman Azhar on 8/13/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import Foundation
import CoreData

@objc(Meta)

class Meta : NSManagedObject {
    
    struct Keys {
        static let TotalPages = "totalPages"
    }
    
    @NSManaged var totalPages: NSNumber
    @NSManaged var location: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Meta", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        totalPages = dictionary[Keys.TotalPages] as! NSNumber
        
    }
    
}
