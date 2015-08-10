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
    
    var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var region = MKCoordinateRegion()
        
        // set map view center
        region.center.latitude = pin.latitude
        region.center.longitude = pin.longitude
        
        // zoom the map to an appropriate level
        region.span.latitudeDelta = 0.2
        region.span.longitudeDelta = 0.2
        
        mapView.setRegion(region, animated: true)
        
        // freeze the map region
        mapView.scrollEnabled = false
        mapView.zoomEnabled = false
        
        // show pin
        var annotation = MKPointAnnotation()
        annotation.coordinate.latitude = pin.latitude
        annotation.coordinate.longitude = pin.longitude
        mapView.addAnnotation(annotation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
