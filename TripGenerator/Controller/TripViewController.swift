//
//  TripViewController.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 1/31/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import UIKit
import SafariServices
import GooglePlaces
import RealmSwift

class TripViewController : UIViewController {
    
    let realm = try! Realm()
    
    var destination : String = ""
    var expediaURL : String = ""
    var kayakURL : String = ""
    var departDate : String = ""
    var arrivalDate : String = ""
    var tripType : String = ""
    var destPlaceID = ""
        
    var placesClient : GMSPlacesClient!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tripDatesLabel: UILabel!
    @IBOutlet weak var tripTypeLabel: UILabel!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationLabel.text = destination
                
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
        
            placesClient?.fetchPlace(fromPlaceID: destPlaceID, placeFields: fields, sessionToken: nil, callback: { (place, error) in
                if let error = error {
                    print("An error occurred: \(error.localizedDescription)")
                    return
                }
                if let place = place {
                    let photoMetadata0 : GMSPlacePhotoMetadata = place.photos![0]
                    let photoMetadata1 : GMSPlacePhotoMetadata = place.photos![1]
                    let photoMetadata2 : GMSPlacePhotoMetadata = place.photos![2]
                    let photoMetadata3 : GMSPlacePhotoMetadata = place.photos![3]
                    
                    self.placesClient?.loadPlacePhoto(photoMetadata0, callback: { (photo, error) in
                        if let error = error {
                            print("Error loading photo metadata \(error.localizedDescription)")
                            return
                        } else {
                            self.imageView1.image = photo
                        }
                    })
                    self.placesClient?.loadPlacePhoto(photoMetadata1, callback: { (photo, error) in
                        if let error = error {
                            print("Error loading photo metadata \(error.localizedDescription)")
                            return
                        } else {
                            self.imageView2.image = photo
                        }
                    })
                    self.placesClient?.loadPlacePhoto(photoMetadata2, callback: { (photo, error) in
                        if let error = error {
                            print("Error loading photo metadata \(error.localizedDescription)")
                            return
                        } else {
                            self.imageView3.image = photo
                        }
                    })
                    self.placesClient?.loadPlacePhoto(photoMetadata3, callback: { (photo, error) in
                        if let error = error {
                            print("Error loading photo metadata \(error.localizedDescription)")
                            return
                        } else {
                            self.imageView4.image = photo
                        }
                    })
                }
            })
    }

    
    // MARK: - Buttons
    
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
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        createTrip()
        // TODO: change button text after pressing once
    }
    
    // MARK: - Helper Methods
    
    func formatDates() {
        departDate = departDate.replacingOccurrences(of: " ", with: "/")
        arrivalDate = arrivalDate.replacingOccurrences(of: " ", with: "/")
    }
    
    // MARK: - Database Methods
    
    func createTrip() {
        let trip = Trip()
        trip.arrivalDate = arrivalDate
        trip.departDate = departDate
        trip.destination = destination
        trip.expediaURL = expediaURL
        trip.kayakURL = kayakURL
//        trip.origin = origin
        trip.tripType = tripType
//        trip.destPlaceID = destPlaceID
        saveTrip(trip: trip)
    }
    
    func saveTrip(trip : Trip) {
        do {
            try realm.write {
                realm.add(trip)
                print("trip saved!")
            }
        } catch {
            print("Error saving trip to Realm \(error)")
        }
    }
    
}
