//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Sulaiman Azhar on 8/10/15.
//  Copyright (c) 2015 kazmi. All rights reserved.
//

import Foundation

class FlickrClient {
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    func getPhotosWithCompletionHandler(latitude: Double, longitude: Double,
        completionHandler: (parsedData: AnyObject!, error: NSError?) -> Void) {
            
            // Configure parameters
            let methodArguments = [
                "method": Constants.METHOD_NAME,
                "api_key": Constants.API_KEY,
                "bbox": createBoundingBoxString(latitude, longitude: longitude),
                "safe_search": Constants.SAFE_SEARCH,
                "extras": Constants.EXTRAS,
                "format": Constants.DATA_FORMAT,
                "nojsoncallback": Constants.NO_JSON_CALLBACK
            ]
        
            // Buil the URL
            let urlString = Constants.BASE_URL + escapedParameters(methodArguments)
            let url = NSURL(string: urlString)!
            
            // Build the request
            let request = NSURLRequest(URL: url)
            
            // Make the request
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) {data, response, downloadError in

                if let error = downloadError {
                    completionHandler(parsedData: nil, error: error)
                } else {
                    
                    var parsingError: NSError? = nil
                    let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                    
                    if let error = parsingError {
                        completionHandler(parsedData: nil, error: error)
                    } else {
                        completionHandler(parsedData: parsedResult, error: nil)
                    }
                    
                }
            }
            
            // Start the request
            task.resume()
    }
    

    // MARK: - Helper Methods
    
    /* create bounding pox parameter string */
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {

        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - Constants.BOUNDING_BOX_HALF_WIDTH, Constants.LON_MIN)
        let bottom_left_lat = max(latitude - Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MIN)
        let top_right_lon = min(longitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LON_MAX)
        let top_right_lat = min(latitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    /* convert a dictionary of parameters to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
}
