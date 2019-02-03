//
//  TripViewController.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 1/31/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import UIKit
import SafariServices
import RealmSwift
import GooglePlaces

class TripViewController : UIViewController {
    
    var location : String = ""
    var expediaURL : String = ""
    var kayakURL : String = ""
    var departDate : String = ""
    var arrivalDate : String = ""
    var tripType : String = ""
    
    var placesClient : GMSPlacesClient!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tripDatesLabel: UILabel!
    @IBOutlet weak var tripTypeLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationLabel.text = location
                
        formatDates()
        
        tripTypeLabel.text = tripType
        
        if (tripType == "Round Trip") {
            tripDatesLabel.text = "\(departDate) - \(arrivalDate)"
        } else {
            tripDatesLabel.text = departDate
        }
        
        placesClient = GMSPlacesClient.shared()
        
        // Specify the place data types to return (in this case, just photos).
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.photos.rawValue))!
        
        placesClient?.fetchPlace(fromPlaceID: "ChIJVZKCP0EvdTERfHvs6AfGjok", placeFields: fields, sessionToken: nil, callback: { (place, error) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let place = place {
                let photoMetadata : GMSPlacePhotoMetadata = place.photos![0]
                
                self.placesClient?.loadPlacePhoto(photoMetadata, callback: { (photo, error) in
                    if let error = error {
                        print("Error loading photo metadata \(error.localizedDescription)")
                        return
                    } else {
                        self.imageView.image = photo
                    }
                })
            }
        })
        
    }
    
    // MARK: URL Buttons
    
    @IBAction func expediaButtonPressed(_ sender: Any) {
        if let url = URL(string: expediaURL) {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        } else {
            print("error with expedia url")
        }
    }
    
    @IBAction func kayakButtonPressed(_ sender: Any) {
        if let url = URL(string: kayakURL) {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - Helper Methods
    
    func formatDates() {
        departDate = departDate.replacingOccurrences(of: " ", with: "/")
        arrivalDate = arrivalDate.replacingOccurrences(of: " ", with: "/")
    }
    
    
}
