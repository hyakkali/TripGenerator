////
////  FavoriteTripsViewController.swift
////  TripGenerator
////
////  Created by Hemanth Yakkali on 2/8/19.
////  Copyright © 2019 Hemanth Yakkali. All rights reserved.
////
//
//import UIKit
//import SwipeCellKit
//import Firebase
//
//class FavoriteTripsViewController: UITableViewController, SwipeTableViewCellDelegate {
//    
////    let realm = try! Realm()
//    
////    var tripArray : Results<Trip>?
//    var tripArray = [Trip]()
//    
//    var selectedTrip : Trip?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Register the custom trip cell
//        self.tableView.register(UINib(nibName: "TripCell", bundle: nil), forCellReuseIdentifier: "customTripCell")
//        
//        self.tableView.rowHeight = 100.0
//        
////        loadTrips()
//    }
//
//    // MARK: - Tableview Datasource Methods
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "customTripCell", for: indexPath) as! CustomTripCell
//        
//        cell.delegate = self
//
//        if let trip = tripArray?[indexPath.row] {
//            
//            cell.destinationLabel.text = trip.destination
//            cell.airportCodesLabel.text = "\(trip.origin) - \(findDestAirportCode(destination: trip.destination))"
//            cell.tripTypeLabel.text = trip.tripType
//            
//            cell.tripDatesLabel.text = trip.tripType == "Round Trip" ? "\(trip.departDate) - \(trip.arrivalDate)" : trip.departDate
//
//        }
//        return cell
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return tripArray?.count ?? 1
//    }
//    
//    // MARK: - Tableview Delegate Methods
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedTrip = tripArray?[indexPath.row]
//        self.performSegue(withIdentifier: "goToTripDetails", sender: self)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let destinationVC = segue.destination as! TripViewController
//        destinationVC.trip = selectedTrip
//        destinationVC.isFavorite = true
//    }
//    
//    // MARK: - Swipe Tableview Delegate Methods
//    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        guard orientation == .right else { return nil }
//        
//        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
//            if let trip = self.tripArray?[indexPath.row] {
//                self.deleteTrip(trip: trip)
//            }
//        }
//        
//        deleteAction.image = UIImage(named: "delete-icon")
//        
//        return [deleteAction]
//        
//    }
//    
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        options.expansionStyle = .destructiveAfterFill
//        return options
//    }
//    
//    // MARK: - Database Methods
//    
////    func loadTrips() {
////        tripArray = realm.objects(Trip.self)
////        
////        tableView.reloadData()
////    }
//    
////    func deleteTrip(trip : Trip) {
////        do {
////            try realm.write {
////                realm.delete(trip)
////            }
////        } catch {
////            print("Error deleting trip")
////        }
////    }
////
////    func findDestAirportCode(destination : String) -> String {
////        return (realm.objects(Place.self).filter("name = %@", destination).first?.airportCode)!
////    }
//
//}
