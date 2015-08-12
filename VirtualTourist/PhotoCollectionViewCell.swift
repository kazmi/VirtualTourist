//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Sulaiman Azhar on 8/11/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
}
