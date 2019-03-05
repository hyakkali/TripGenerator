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
import FaveButton
import Firebase

class TripViewController : UIViewController, FaveButtonDelegate {
    
    var destination : String = ""
    var origin : String = ""
    var originCode : String = ""
    var destinationCode : String = ""
    var destinationCountry : String = ""
    var expediaURL : String = ""
    var kayakURL : String = ""
    var departDate : String = ""
    var arrivalDate : String = ""
    var tripType : String = ""
    var destPlaceID = ""
    var isFavorite = false
    
    var trip : Trip? {
        didSet{
            loadGlobalVariables()
        }
    }
    
    var placesClient : GMSPlacesClient!
    
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var destinationCountryLabel: UILabel!
    @IBOutlet weak var tripDatesLabel: UILabel!
    @IBOutlet weak var tripTypeLabel: UILabel!
    @IBOutlet weak var airportCodesLabel: UILabel!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        destinationLabel.text = destination
        
        destinationCountryLabel.text = destinationCountry
        
        tripTypeLabel.text = tripType
        
        airportCodesLabel.text = "\(originCode) - \(destinationCode)"
        
        createFaveButton()
        
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
    
    override func willMove(toParent parent: UIViewController?) {
        if (parent == nil && isFavorite) {
            saveTrip(trip: trip!)
        }
    }
    
    // MARK: - FaveButton Delegate Methods
    
    func createFaveButton() {
        let faveButton = FaveButton(
            frame: CGRect(x: 300, y: 92, width: 30, height: 30),
            faveIconNormal: UIImage(named: "heart")
        )
        
        faveButton.delegate = self
        view.addSubview(faveButton)
        
        faveButton.isSelected = isFavorite
        faveButton.isUserInteractionEnabled = !isFavorite
    }
    
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
        print(selected)
        if selected {
            faveButton.isUserInteractionEnabled = false
            saveTrip(trip: trip!)
        }
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
    
    // MARK: - Helper Methods
    
    func loadGlobalVariables() {
        destination = trip!.destination
        origin = trip!.origin
        destinationCode = trip!.destinationCode
        originCode = trip!.originCode
        departDate = trip!.departDate
        arrivalDate = trip!.arrivalDate
        kayakURL = trip!.kayakURL
        expediaURL = trip!.expediaURL
        tripType = trip!.tripType
        destPlaceID = trip!.destPlaceID
        destinationCountry = trip!.destinationCountry
    }
    
    // MARK: - Database Methods
    
    func saveTrip(trip : Trip) {
        
        let userID = Auth.auth().currentUser?.uid
        let tripsDB = Database.database().reference().child("trips").child(userID!)
        let key = tripsDB.childByAutoId().key

        let tripDict = [
            "id" : key!,
            "origin" : origin,
            "destination" : destination,
            "originCode" : originCode,
            "destinationCode" : destinationCode,
            "departDate" : departDate,
            "arrivalDate" : arrivalDate,
            "tripType" : tripType,
            "expediaURL" : expediaURL,
            "kayakURL" : kayakURL,
            "destPlaceID" : destPlaceID
        ]
        
        tripsDB.child(key!).setValue(tripDict) {
            (error, reference) in
            if error != nil {
                // TODO: better error handling
                print(error!)
            } else {
                print("Trip saved successfully")
            }
        }
        
    }
    
}
