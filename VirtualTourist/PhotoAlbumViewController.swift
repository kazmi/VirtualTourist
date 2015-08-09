//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Sulaiman Azhar on 8/9/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
