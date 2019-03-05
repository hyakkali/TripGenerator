//
//  FavoriteTripsViewController.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 2/8/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import UIKit
import SwipeCellKit
import Firebase

class FavoriteTripsViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var tripsArray = [Trip]()
    
    var selectedTrip : Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the custom trip cell
        self.tableView.register(UINib(nibName: "TripCell", bundle: nil), forCellReuseIdentifier: "customTripCell")
        
        self.tableView.rowHeight = 100.0
        
        loadTrips()
    }
    
    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customTripCell", for: indexPath) as! CustomTripCell
        
        cell.delegate = self
        
        let trip = tripsArray[indexPath.row]
        
        cell.destinationLabel.text = "\(trip.destination), \(trip.destinationCountry)"
        cell.airportCodesLabel.text = "\(trip.originCode) - \(trip.destinationCode)"
        cell.tripTypeLabel.text = trip.tripType
        
        cell.tripDatesLabel.text = trip.tripType == "Round Trip" ? "\(trip.departDate) - \(trip.arrivalDate)" : trip.departDate
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripsArray.count
    }
    
    // MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTrip = tripsArray[indexPath.row]
        self.performSegue(withIdentifier: "goToTripDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TripViewController
        destinationVC.trip = selectedTrip
        destinationVC.isFavorite = true
    }
    
    // MARK: - Swipe Tableview Delegate Methods
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteTrip(trip: self.tripsArray[indexPath.row])
            self.tripsArray.remove(at: indexPath.row)
        }
        
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructiveAfterFill
        return options
    }
    
    // MARK: - Database Methods
    
    func loadTrips() {
        
        let userID = Auth.auth().currentUser?.uid
        let tripsDB = Database.database().reference().child("trips").child(userID!)
        
        tripsDB.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let value = snapshot.value as? NSDictionary {
                for trip in value {
                    let data = trip.value as! NSDictionary
                    
                    let id = data["id"] as! String
                    let destination = data["destination"] as! String
                    let origin = data["origin"] as! String
                    let arrivalDate = data["arrivalDate"] as! String
                    let departDate = data["departDate"] as! String
                    let destinationCode = data["destinationCode"] as! String
                    let originCode = data["originCode"] as! String
                    let destinationCountry = data["destinationCountry"] as! String
                    let destPlaceID = data["destPlaceID"] as! String
                    let expediaURL = data["expediaURL"] as! String
                    let kayakURL = data["kayakURL"] as! String
                    let tripType = data["tripType"] as! String
                    
                    let trip = Trip()
                    trip.id = id
                    trip.destination = destination
                    trip.origin = origin
                    trip.arrivalDate = arrivalDate
                    trip.departDate = departDate
                    trip.destinationCode = destinationCode
                    trip.originCode = originCode
                    trip.tripType = tripType
                    trip.destinationCountry = destinationCountry
                    trip.destPlaceID = destPlaceID
                    trip.expediaURL = expediaURL
                    trip.kayakURL = kayakURL
                    
                    self.tripsArray.append(trip)
                }
                
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func deleteTrip(trip : Trip) {
        
        let userID = Auth.auth().currentUser?.uid
        let tripsDB = Database.database().reference().child("trips").child(userID!)
        
        let currTripRef = tripsDB.child(trip.id)
        currTripRef.removeValue { error, _ in
            if (error != nil) {
                print(error!)
            } else {
                print("Trip deleted successfully")
                
                self.tableView.reloadData()
            }
        }
    }
    
}
