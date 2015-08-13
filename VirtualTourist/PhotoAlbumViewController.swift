//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Sulaiman Azhar on 8/9/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,
    NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var collectionActionButton: UIBarButtonItem!
    
    var pin: Pin!
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    var selectedIndexes = [NSIndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerAndZoomMapForSelectedPin()
        
        // Start the fetched results controller
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        
        if let error = error {
            println("Error performing initial fetch: \(error)")
        }
        
    }
    
    func centerAndZoomMapForSelectedPin() {
        
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
    
    // Layout the collection view
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that cells take up 1/3 of the width,
        // with no space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.photosCollectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        photosCollectionView.collectionViewLayout = layout
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if pin!.photos.isEmpty {
            getNewCollection()
        }
    }
    
    // MARK: - Configure Cell
    
    func configureCell(cell: PhotoCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        if let index = find(selectedIndexes, indexPath) {
            cell.photoImageView.alpha = 0.25
        } else {
            cell.photoImageView.alpha = 1.0
        }
        
    }
    
    // MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        
        if sectionInfo.numberOfObjects == 0 {
            photosCollectionView.hidden = true
        } else {
            photosCollectionView.hidden = false
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        let fileURL = FlickrClient.photoFileURL(photo.id!)
        
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) == true {
            cell.photoImageView.image = UIImage(contentsOfFile: fileURL.path!)
        } else {
            cell.photoImageView.image = UIImage(named: "placeholder")
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.hidden = false
            
            // Start the task that will eventually download the image
            let task = FlickrClient.sharedInstance().taskForImage(photo.imageURL!) { data, error in
                
                if let error = error {
                    println("Poster download error: \(error.localizedDescription)")
                }
                
                if let data = data {
                    
                    // Create the image
                    let image = UIImage(data: data)
                    
                    // Save to documents directory
                    let bytes = UIImageJPEGRepresentation(image, 1.0);
                    bytes.writeToFile(fileURL.path!, atomically: true)
                    
                    // update the cell later, on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.photoImageView.image = image
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.hidden = true
                    }
                }
            }
            
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            cell.taskToCancelifCellIsReused = task
        }
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        
        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        if let index = find(selectedIndexes, indexPath) {
            selectedIndexes.removeAtIndex(index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        // Then reconfigure the cell
        configureCell(cell, atIndexPath: indexPath)
        
        // And update the buttom button
        updateBottomButton()
    }
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    // MARK: - NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        
        let predicate = NSPredicate(format: "location == %@", self.pin)
        fetchRequest.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            println("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        photosCollectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.photosCollectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.photosCollectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.photosCollectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    func getNewCollection() {
        
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
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    let photoToBeAdded = Photo(dictionary: dictionary, context: self.sharedContext)
                                    photoToBeAdded.location = self.pin
                                }
                            }
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                CoreDataStackManager.sharedInstance().saveContext()
                                
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func deleteAllPhotos() {
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
    }
    
    func deleteSelectedPhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            sharedContext.deleteObject(photo)
        }
        
        selectedIndexes = [NSIndexPath]()
        
        updateBottomButton()
    }
    
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            collectionActionButton.title = "Remove Selected Photos"
        } else {
            collectionActionButton.title = "New Collection"
        }

    }
    
    @IBAction func bottomButtonAction(sender: AnyObject) {
        
        if selectedIndexes.isEmpty {
            deleteAllPhotos()
            getNewCollection()
        } else {
            deleteSelectedPhotos()
        }

        
    }

}
