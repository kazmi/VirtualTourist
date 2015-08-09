//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Sulaiman Azhar on 8/1/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editLabel: UILabel!
    
    var annotations: [MKPointAnnotation] = [MKPointAnnotation]()

    let touchAndHoldGesture = UILongPressGestureRecognizer()
    
    var editMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        touchAndHoldGesture.addTarget(self, action: "mapTouchAndHold:")
        mapView.addGestureRecognizer(touchAndHoldGesture)
        mapView.delegate = self
        
    }
    
    func mapTouchAndHold(sender: UIGestureRecognizer) {
        
        if (editMode == false) {
        
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
            
                annotations.append(annotation)
                mapView.addAnnotation(annotation)
            
                break;
            
            default:
                // do nothing
                break;
            }
            
        }

    }
    
    // MARK: - Actions
    
    @IBAction func toggleEditMode(sender: AnyObject) {
        
        if editMode == false {
            
            editButton.title = "Done"
            
            UIView.animateWithDuration(0.2, animations: {
                self.view.frame.origin.y -= self.editLabel.frame.height
            })
            
            editMode = true
            
        } else {
            
            editButton.title = "Edit"
            
            UIView.animateWithDuration(0.2, animations: {
                self.view.frame.origin.y += self.editLabel.frame.height
            })
            
            editMode = false
            
        }
        
    }
    
    // MARK: - Map View Delegate
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {

        mapView.deselectAnnotation(view.annotation, animated: true)
        
        if editMode == true {
            
            var index : Int = 0
            for annotation in annotations {
                if annotation == view.annotation as! MKPointAnnotation {
                    break;
                } else {
                    index++
                }
            }
        
            mapView.removeAnnotation(view.annotation)
            annotations.removeAtIndex(index)
            
        } else {
            
            performSegueWithIdentifier("showPhotoAlbum", sender: nil)
            
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
