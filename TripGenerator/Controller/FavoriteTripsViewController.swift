//
//  FavoriteTripsViewController.swift
//  TripGenerator
//
//  Created by Hemanth Yakkali on 2/8/19.
//  Copyright © 2019 Hemanth Yakkali. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteTripsViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var tripArray : Results<Trip>?
    
    var selectedTrip : Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTrips()
    }

    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)

        if let trip = tripArray?[indexPath.row] {
            if trip.tripType == "Round Trip" {
                let cellText = "Round Trip from \(trip.origin) to \(trip.destination) \(trip.departDate)-\(trip.arrivalDate)"
                cell.textLabel?.text = cellText
            } else {
                let cellText = "One Way from \(trip.origin) to \(trip.destination) on \(trip.departDate)"
                cell.textLabel?.text = cellText
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripArray?.count ?? 1
    }
    
    // MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTrip = tripArray?[indexPath.row]
        self.performSegue(withIdentifier: "goToTripDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TripViewController
        destinationVC.trip = selectedTrip
    }
    
    func loadTrips() {
        tripArray = realm.objects(Trip.self)
        
        tableView.reloadData()
    }

}
