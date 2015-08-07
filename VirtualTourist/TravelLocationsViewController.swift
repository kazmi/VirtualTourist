//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Sulaiman Azhar on 8/1/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    let touchAndHoldGesture = UILongPressGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        touchAndHoldGesture.addTarget(self, action: "mapTouchAndHold:")
        mapView.addGestureRecognizer(touchAndHoldGesture)
        
    }
    
    func mapTouchAndHold(sender: UIGestureRecognizer) {
        
        switch(touchAndHoldGesture.state) {
        // upon releasing the finger
        case UIGestureRecognizerState.Ended:
            
            // convert touch point to coordinate
            var point: CGPoint = sender.locationInView(mapView)
            
            var coordinate: CLLocationCoordinate2D = mapView.convertPoint(point,
                toCoordinateFromView: mapView)
            
            // add annotation on the coordinate
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            mapView.addAnnotation(annotation)
            
            break;
            
        default:
            // do nothing
            break;
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
