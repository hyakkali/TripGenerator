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
        
        self.tableView.register(UINib(nibName: "TripCell", bundle: nil), forCellReuseIdentifier: "customTripCell")
        self.tableView.rowHeight = 100.0
//        self.tableView.estimatedRowHeight = 200.0
        
        loadTrips()
    }

    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customTripCell", for: indexPath) as! CustomTripCell

        if let trip = tripArray?[indexPath.row] {
            
            cell.destinationLabel.text = trip.destination
            cell.airportCodesLabel.text = "\(trip.origin) - \(findDestAirportCode(destination: trip.destination))"
            cell.tripTypeLabel.text = trip.tripType

            if trip.tripType == "Round Trip" {
                cell.tripDatesLabel.text = "\(trip.departDate) - \(trip.arrivalDate)"
            } else {
                cell.tripDatesLabel.text = trip.departDate
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
        destinationVC.hideFavoriteButton = true
    }
    
    // MARK: - Database Methods
    
    func loadTrips() {
        tripArray = realm.objects(Trip.self)
        
        tableView.reloadData()
    }
    
    func findDestAirportCode(destination : String) -> String {
        return (realm.objects(Place.self).filter("name = %@", destination).first?.airportCode)!
    }

}
