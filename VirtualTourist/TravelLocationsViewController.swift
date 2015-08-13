//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Sulaiman Azhar on 8/1/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editLabel: UILabel!
    
    var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
    var pins: [Pin] = [Pin]()

    let touchAndHoldGesture = UILongPressGestureRecognizer()
    
    var editMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        touchAndHoldGesture.addTarget(self, action: "mapTouchAndHold:")
        mapView.addGestureRecognizer(touchAndHoldGesture)
        mapView.delegate = self
        
        pins = fetchAllPins()
        
        annotations.removeAll(keepCapacity: true)
        
        for pin in pins {
            var annotation = MKPointAnnotation()
            annotation.coordinate.latitude = pin.latitude
            annotation.coordinate.longitude = pin.longitude
            annotations.append(annotation)
            mapView.addAnnotation(annotation)
        }
        
    }
    
    func prefetchPhotos(pin: Pin!) {
        
        FlickrClient.sharedInstance().getPhotosWithCompletionHandler(pin.latitude, longitude: pin.longitude) { (JSONResult, error) in
            
            if(error == nil) {
                
                if let photosDictionary = JSONResult.valueForKey("photos") as? [String:AnyObject] {
                    
                    var totalPhotosVal = 0
                    if let totalPhotos = photosDictionary["total"] as? String {
                        totalPhotosVal = (totalPhotos as NSString).integerValue
                    }
                    
                    if totalPhotosVal > 0 {
                        if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                            for index in 0...photosArray.count-1 {
                                
                                let photoDictionary = photosArray[index] as [String: AnyObject]
                                
                                let photoID = photoDictionary["id"] as? String
                                let imageUrlString = photoDictionary["url_m"] as? String
                                
                                let dictionary: [String : AnyObject] = [
                                    Photo.Keys.ID : photoID!,
                                    Photo.Keys.ImageURL : imageUrlString!
                                ]
                                
                                let photoToBeAdded = Photo(dictionary: dictionary, context: self.sharedContext)
                                photoToBeAdded.location = pin
                                
                                let task = FlickrClient.sharedInstance().taskForImage(imageUrlString!) { data, error in
                                    
                                    if let error = error {
                                        println("Poster download error: \(error.localizedDescription)")
                                    }
                                    
                                    if let data = data {
                                        
                                        let fileURL = FlickrClient.photoFileURL(photoID!)
                                        let image = UIImage(data: data)
                                        let bytes = UIImageJPEGRepresentation(image, 1.0);
                                        bytes.writeToFile(fileURL.path!, atomically: true)
                                        println("pre-fetched \(photoID!).jpg")
                                        
                                    }
                                }
                                
                            }
                            
                            CoreDataStackManager.sharedInstance().saveContext()
                            
                        }
                    }
                }
            }
        }

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
                
                // add annotation on the coordinate and persist it
                var annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
            
                let dictionary: [String : AnyObject] = [
                    Pin.Keys.Latitude : coordinate.latitude,
                    Pin.Keys.Longitude : coordinate.longitude
                ]
                
                let pinToBeAdded = Pin(dictionary: dictionary, context: sharedContext)
                
                self.pins.append(pinToBeAdded)
                annotations.append(annotation)
                mapView.addAnnotation(annotation)
                CoreDataStackManager.sharedInstance().saveContext()
                prefetchPhotos(pinToBeAdded)
            
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
        
        var index : Int = 0
        for annotation in annotations {
            if annotation == view.annotation as! MKPointAnnotation {
                break;
            } else {
                index++
            }
        }
        
        if editMode == true {
            
            mapView.removeAnnotation(view.annotation)
            annotations.removeAtIndex(index)
            
            // Remove the actor from the context
            let pin = pins[index]
            sharedContext.deleteObject(pin)
            pins.removeAtIndex(index)
            CoreDataStackManager.sharedInstance().saveContext()
            
        } else {
            
            performSegueWithIdentifier("showPhotoAlbum", sender: pins[index])
            
        }

    }
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    func fetchAllPins() -> [Pin] {
        
        let error: NSErrorPointer = nil
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Execute the Fetch Request
        let results = sharedContext.executeFetchRequest(fetchRequest, error: error)
        
        // Check for Errors
        if error != nil {
            println("Error in fectchAllActors(): \(error)")
        }
        
        return results as! [Pin]
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass the pin object to the photo album view controller.
        let destination = segue.destinationViewController as! PhotoAlbumViewController
        destination.pin = sender as! Pin
    }

}
