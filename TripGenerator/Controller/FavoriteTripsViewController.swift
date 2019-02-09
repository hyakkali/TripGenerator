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
    
    let array = ["hey", "hello", "lmao"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTrips()
    }

    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)

        if let trip = tripArray?[indexPath.row] {
            cell.textLabel?.text = trip.destination + trip.departDate + trip.arrivalDate
        } else {
            cell.textLabel?.text = "No Trips Have Been Favorited Yet"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripArray?.count ?? 1
    }
    
    // MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("clicked!")
    }
    
    func loadTrips() {
        tripArray = realm.objects(Trip.self)
        
        tableView.reloadData()
    }

}
